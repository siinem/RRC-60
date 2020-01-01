%-------------------------------------------------------------------------
% Classification accuracy of GTG (with and without Priors) is computed for 
% each training set in increased sizes. 
% 
% priors: softmax output of ResNet152 when it is initialized by ImageNet 
%         and the whole network is finetuned by the training set consists of 
%         [number of labeled images per class] * 60 (classes) number of
%         images.
%
% split: shows the training (split = 1), validation (split = 2) and 
%        test (split = 3) sets
%
% W_prior = 0 : implements GTG without Prior
% W_prior = 1 : implements GTG with Prior
% 
% Connectivity rule is adopted in sparsifying the similarity matrix (k = floor(log2(n)) +1).
% Perona rule (nn = 8) is adopted to set the sigma values in the computation
% of similarity matrix 
%
%--------------------------------------------------------------------------
function [acc_gtg_wo, acc_gtg_w]  = compute_GTG(path,param,trial_no)
%--------------------------------------------------------------------------

acc_gtg_wo = zeros(1,length(param.set));
acc_gtg_w  = zeros(1,length(param.set));

disp(['TRIAL ', num2str(trial_no)]);

for tr_no = 1:length(param.set)
    
    load(sprintf(path.load_split,    num2str(trial_no),num2str(param.set(tr_no))),'split','class','imno');
    load(sprintf(path.load_priors,   param.side,num2str(trial_no),num2str(param.set(tr_no))) , 'priors');
    load(sprintf(path.load_features, param.side,num2str(trial_no),num2str(param.set(tr_no))) , 'features');    
    
    % Standadize the features by subtracting mean of the values of the 
    % labeled set features and dividing by std of the values of the labeled set
    % features
    tr_mean  = repmat( mean( features((split == 1),:),1 ),    [size(features,1),1]);
    tr_std   = repmat(  std( features((split == 1),:),[],1 ), [size(features,1),1]);
    features = (features - tr_mean)./tr_std;
    
    % Classification accuracy of GTG Without Prior
    W_prior = 0; 
    [~, acc_gtg_wo(tr_no)] = run_gtg(features, split, class, imno, param.nr_classes, priors, W_prior);
    disp(['GTG W/O Prior - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_gtg_wo(tr_no))])
    
    % Classification accuracy of GTG With Prior
    W_prior = 1;
    [~, acc_gtg_w(tr_no)] = run_gtg(features,split,class,imno,param.nr_classes,priors,W_prior);
    disp(['GTG W/  Prior - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_gtg_w(tr_no))])
    
end

end

%--------------------------------------------------------------------------
function [labeling_info, acc_test] = run_gtg(features, split, class, imno, nr_classes, priors, use_P)
%--------------------------------------------------------------------------

% prepare the matrix W
train_idx = find(split==1);
test_idx  = find(split==3);

[W_organized, labels_organized, imno_organized, labelled, unlabelled, unlab_priors ] = create_mapping(features, train_idx, test_idx, class, imno, priors);

% Sparsify W
k = floor(log2(size(W_organized,1)))+1;
W_sparsified = sparsify_W(W_organized,k);

P = zeros(length(labels_organized),nr_classes);
[cl, b] = grp2idx(labels_organized(labelled));

P(labelled, :) = full(ind2vec(cl'))';

if use_P == 1
    P(unlabelled, :) = unlab_priors(unlabelled,:);
else
    P(unlabelled, :) = ones(size(unlabelled, 1), numel(b)) / numel(b);
end

[HC, ~] = gtg(W_sparsified, P);


labeling_info = [imno_organized, labels_organized, HC];

acc_test = mean(HC(unlabelled) == labels_organized(unlabelled));
end

%--------------------------------------------------------------------------
function [W_organized, labels_organized, imno_organized, labelled, unlabelled,unlab_priors ] = create_mapping(features,train_idx,val_idx,class, imno, priors)
%--------------------------------------------------------------------------
all_indices = [train_idx;val_idx];

features = features(all_indices,:);
W_organized = compute_similarity(features,8);

unlab_priors = priors(all_indices,:);
labels_organized = class(all_indices);
imno_organized = imno(all_indices);

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