%%--------------------------------------------------------------------------
% Fusion operation is accomplished by using similarity fusion scheme where 
% convex combination of similarity matrices created for each coin
% side, i.e. Observe (O) and Reverse (R), images is computed. Then, GTG is 
% run using the fused similarity matrix.  
% 
%--------------------------------------------------------------------------
% priors: softmax output of ResNet152 when it is initialized by ImageNet 
%         and the whole network is finetuned by the training set consists  
%         of [number of labeled images per class] * 60 (classes) number of
%         images.
% 
% split: shows the training (split = 1), validation (split = 2) and 
%        test (split = 3) set split
%--------------------------------------------------------------------------
% 
% 1. alpha_W to combine wimilarity matrices W(O) and W(R) is tuned on the 
%    validation set. 
% 2. Using the tuned alpha_W, convex combination of similarity matrices 
%    that were constructed for each coin side is computed by 
%    W_fused = alpha_W*(W(O)) + (1-alpha_W)*(W(R)) 
% 3. GTG without Priors is implemented using W_fused.
% 4. To implement GTG with Priors, alpha_P is tuned on the validation set 
%    by using tuned alpha_W. Then, convex combination of priors
%    from each coin side is computed in a similar way:
%    Priors_fused = alpha_P*(Priors(O)) + (1-alpha_P)*(Priors(R)) 
% 
%--------------------------------------------------------------------------
function [acc_gtg_wo,acc_gtg_w]  = compute_GTG_fusion(path,param,trial_no)
%--------------------------------------------------------------------------

acc_gtg_wo = zeros(1,length(param.set));
acc_gtg_w  = zeros(1,length(param.set));

disp(['TRIAL ', num2str(trial_no)]);

for tr_no = 1:length(param.set)
    
    
    load(sprintf(path.load_split, num2str(trial_no),num2str(param.set(tr_no))),'split','class','imno');
    
    % Load priors (softmax outputs of ResNet152)
    priors_O = load(sprintf(path.load_priors,  'O',num2str(trial_no),num2str(param.set(tr_no))) , 'priors');
    priors_R = load(sprintf(path.load_priors,  'R',num2str(trial_no),num2str(param.set(tr_no))) , 'priors');
    priors_O = priors_O.priors;
    priors_R = priors_R.priors;
    
    % Load features
    features_O = load(sprintf(path.load_features,'O',num2str(trial_no),num2str(param.set(tr_no))) , 'features');
    features_R = load(sprintf(path.load_features,'R',num2str(trial_no),num2str(param.set(tr_no))) , 'features');
    features_O = features_O.features;
    features_R = features_R.features;
    
    % Standadize the features
    tr_mean  = repmat( mean( features_O((split == 1),:),1 ),    [size(features_O,1),1]);
    tr_std   = repmat(  std( features_O((split == 1),:),[],1 ), [size(features_O,1),1]);
    features_O = (features_O - tr_mean)./tr_std;
    
    tr_mean  = repmat( mean( features_R((split == 1),:),1 ),    [size(features_R,1),1]);
    tr_std   = repmat(  std( features_R((split == 1),:),[],1 ), [size(features_R,1),1]);
    features_R = (features_R - tr_mean)./tr_std;
    
    % Performance of GTG withOUT Prior
    W_prior = 0;
    best_alpha = 0;
    [ acc_gtg_wo(tr_no), best_alpha] = run_gtg_for_fusion(features_O,features_R, param.alphas, split, class, param.nr_classes, priors_O, priors_R, W_prior, best_alpha);
    disp(['FUSION - GTG W/O Prior - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_gtg_wo(tr_no))])
    
    % Performance of GTG with Prior
    W_prior = 1;
    [ acc_gtg_w(tr_no), ~] = run_gtg_for_fusion(features_O,features_R, param.alphas, split, class, param.nr_classes, priors_O, priors_R, W_prior, best_alpha);
    disp(['FUSION - GTG W/  Prior - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_gtg_w(tr_no))])
end
end


%--------------------------------------------------------------------------
function [ acc_test, alpha_W] = run_gtg_for_fusion(features_1,features_2, alphas, split, class, nr_classes, priors_1, priors_2, use_P, alpha_W)
%--------------------------------------------------------------------------
% Compute best alpha on the validation set
train_idx = find(split==1);
test_idx  = find(split==2);
[all_indices, labelled, unlabelled ] = create_mapping(train_idx,test_idx);

W1_valSet = compute_similarity(features_1(all_indices,:),8);
W2_valSet = compute_similarity(features_2(all_indices,:),8);

if use_P == 0
    alpha_W = tune_alpha_for_W(W1_valSet,W2_valSet,alphas,class(all_indices), nr_classes, priors_1(all_indices,:),labelled, unlabelled , use_P);
    priors = priors_1;
end

if use_P == 1
    W_valSet = W1_valSet.*alpha_W + W2_valSet.* (1-alpha_W);
    alpha_P = tune_alpha_for_prior(W_valSet, alphas, class(all_indices), nr_classes, priors_1(all_indices,:),priors_2(all_indices,:), labelled, unlabelled );
    priors = priors_1.*alpha_P + priors_2.* (1-alpha_P);
end

%--------------------------------------------------------------------------
% Run GTG for class decisions on the test set
train_idx = find(split==1);
test_idx  = find(split==3);
[all_indices, labelled, unlabelled ] = create_mapping(train_idx,test_idx);

W1 = compute_similarity(features_1(all_indices,:),8);
W2 = compute_similarity(features_2(all_indices,:),8);
 W = W1.*alpha_W + W2.* (1-alpha_W);

% Sparsify W
k = floor(log2(size(W,1)))+1;
W_sparsified = sparsify_W(W,k);

labels_organized =  class(all_indices);
    unlab_priors = priors(all_indices,:);

P = zeros(length(labels_organized),nr_classes);
[cl, b] = grp2idx(labels_organized(labelled));

P(labelled, :) = full(ind2vec(cl'))';

if use_P == 1
    P(unlabelled, :) = unlab_priors(unlabelled,:);
else
    P(unlabelled, :) = ones(size(unlabelled, 1), numel(b)) / numel(b);
end

[HC, ~] = gtg(W_sparsified, P);
% labeling_info = [imno_organized, labels_organized, HC];
acc_test = mean(HC(unlabelled) == labels_organized(unlabelled));
end


%--------------------------------------------------------------------------
function best_alpha = tune_alpha_for_W(W1, W2, alpha_set, class, nr_classes, priors, labelled, unlabelled , use_P)
%--------------------------------------------------------------------------
% Tune \alpha on VAL set
for j=1:length(alpha_set)
    W = W1.*alpha_set(j) + W2.* (1-alpha_set(j));
    acc_val(j) = run_gtg_on_valSet(W, class, nr_classes, priors, labelled, unlabelled , use_P);
end
[~,idx] = find(ismember(acc_val, max(acc_val(:))));
best_alpha = alpha_set(idx);

if length(best_alpha)>1
    t = randperm(length(best_alpha));
    best_alpha = best_alpha(t(1));
end

end

%--------------------------------------------------------------------------
function best_alpha = tune_alpha_for_prior(W, alpha_set,class,  nr_classes, s1_priors, s2_priors,labelled, unlabelled)
%--------------------------------------------------------------------------
use_P = 1;
% Tune \alpha on VAL set
for j=1:length(alpha_set)
    priors = s1_priors.*alpha_set(j) + s2_priors.* (1-alpha_set(j));
    acc_val(j) = run_gtg_on_valSet(W,  class, nr_classes, priors, labelled, unlabelled , use_P);
end

[~,idx] = find(ismember(acc_val, max(acc_val(:))));
best_alpha = alpha_set(idx);

if length(best_alpha) > 1
    t = randperm(length(best_alpha));
    best_alpha = best_alpha(t(1));
end

end

%--------------------------------------------------------------------------
function acc_test = run_gtg_on_valSet(W, class, nr_classes, priors, labelled,unlabelled,use_P)
%--------------------------------------------------------------------------

% Sparsify W
k = floor(log2(size(W,1)))+1;
W_sparsified = sparsify_W(W,k);

P = zeros(length(class),nr_classes);
[cl, b] = grp2idx(class(labelled));

P(labelled, :) = full(ind2vec(cl'))';

if use_P == 1
    P(unlabelled, :) = priors(unlabelled,:);
else
    P(unlabelled, :) = ones(size(unlabelled, 1), numel(b)) / numel(b);
end

[HC, ~] = gtg(W_sparsified, P);
acc_test = mean(HC(unlabelled) == class(unlabelled));
end

%--------------------------------------------------------------------------
function [all_indices, labelled, unlabelled ] = create_mapping(train_idx,val_idx)
%--------------------------------------------------------------------------
all_indices = [train_idx;val_idx];
labelled = (1:length(train_idx))';
unlabelled = (length(train_idx) + 1 : length(train_idx) + length(val_idx))';
end

%--------------------------------------------------------------------------
function W = compute_similarity(features,nn)
%--------------------------------------------------------------------------
D = pdist(features,'euclidean');
D = squareform(D);

[V] = sort(D,2) + 1e-16;
T = V(:,nn);
sigmas = T*T';

W = exp(-(D.*D)./sigmas);
W = W .*not(eye(size(W)));
end

%--------------------------------------------------------------------------
function W = sparsify_W(W,k)
%--------------------------------------------------------------------------
%k = 2;
% sigmas = sort(dist_mat,2,'ascend');
% sigmas = sigmas(:,8) + 1e-16;
% matrice_prodotti_sigma = sigmas*sigmas';
% dist_mat_2 = -dist_mat./matrice_prodotti_sigma;
% W = exp(dist_mat_2);
% W(1:1+size(W,1):end) = 0;
sel_W = sort(W,2,'descend');
W(~ismember( W, sel_W(:,1:k)))=0;

end