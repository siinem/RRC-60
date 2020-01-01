%%--------------------------------------------------------------------------
% Classification decisions for ResNet 152 are made by adopting information 
% from both , i.e. Observe (O) and Reverse (R), sides of each coin. 
%
% priors: softmax output of ResNet152 when it is initialized by ImageNet 
%         and the whole network is finetuned by the training set consists of 
%         [number of labeled images per class] * 60 (classes) number of
%         images.
% 
% split: shows the training (split = 1), validation (split = 2) and 
%        test (split = 3) set split
%--------------------------------------------------------------------------
% 
% 1. Parameter alpha is tuned on the validation set 
% 2. Convex combination of priors from both sides is computed by 
%    priors = alpha*(priors(O)) + (1-alpha)*(priors(R)) 
% 3. Classification decision is made by max(priors)
% 
% 
%--------------------------------------------------------------------------
function acc_resnet = compute_ResNet_fusion(path,param,trial_no)
%--------------------------------------------------------------------------

acc_resnet = zeros(1,length(param.set));

disp(['TRIAL ', num2str(trial_no)]);

for tr_no = 1:length(param.set)
    
    load(sprintf(path.load_split,num2str(trial_no),num2str(param.set(tr_no))),'split','class','imno');
    
    % Load softmax outputs computed for each side of coins
    priors_O = load(sprintf(path.load_priors,'O',num2str(trial_no),num2str(param.set(tr_no))) ,'priors'); 
    priors_R = load(sprintf(path.load_priors,'R',num2str(trial_no),num2str(param.set(tr_no))) ,'priors');
    priors_O = priors_O.priors;
    priors_R = priors_R.priors;
    
    % Tune alpha on validation set 
    best_alpha = tune_alpha_for_prior(param.alphas, split, class, imno, param.nr_classes, priors_O, priors_R);
    
    % Convex combination of priors from each side
    priors = priors_O.*best_alpha + priors_R.* (1-best_alpha);
    
    % Classification accuracy 
    [ ~ , acc_resnet(tr_no)] = perf_net(split,class,imno,param.nr_classes,priors);
    
    disp(['FUSION - RESNET - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_resnet(tr_no))])
end

end


%--------------------------------------------------------------------------
function best_alpha = tune_alpha_for_prior(alpha_set,split,class,imno, nr_classes, s1_priors, s2_priors)
%--------------------------------------------------------------------------

% Tune \alpha on VAL set
for j=1:length(alpha_set)
    alpha = alpha_set(j);
    priors = s1_priors.*alpha + s2_priors.* (1-alpha);
    acc_val(j) = perf_net_on_valSet(split,class,imno,nr_classes,priors);
end

[~,idx] = find(ismember(acc_val, max(acc_val(:))));
best_alpha = alpha_set(idx);

if length(best_alpha) > 1
    t = randperm(length(best_alpha));
    best_alpha = best_alpha(t(1));
end

end

%--------------------------------------------------------------------------
function acc_test = perf_net_on_valSet(split,class,imno,nr_classes,priors)
%--------------------------------------------------------------------------

train_idx = find(split==1);
test_idx  = find(split==2);

[labels_organized, ~, labelled, unlabelled, unlab_priors ] = create_mapping_for_ResNet(train_idx, test_idx, class, imno, priors);

P = zeros(length(labels_organized),nr_classes);
[cl, ~] = grp2idx(labels_organized(labelled));

P(labelled, :)   = full(ind2vec(cl'))';
P(unlabelled, :) = unlab_priors(unlabelled,:);
[~, BB ] = max(P(unlabelled,:),[],2);
acc_test = mean(BB == labels_organized(unlabelled));

end

%--------------------------------------------------------------------------
function [labeling_info, acc_test] = perf_net(split,class,imno,nr_classes,priors)
%--------------------------------------------------------------------------
train_idx = find(split==1);
test_idx  = find(split==3);

[labels_organized, imno_organized, labelled, unlabelled, unlab_priors ] = create_mapping_for_ResNet(train_idx, test_idx, class, imno, priors);

P = zeros(length(labels_organized),nr_classes);
[cl, ~] = grp2idx(labels_organized(labelled));

P(labelled, :)   = full(ind2vec(cl'))';
P(unlabelled, :) = unlab_priors(unlabelled,:);
[~, classes_ ] = max(P(unlabelled,:),[],2);

labeling_info = [imno_organized, labels_organized, [labels_organized(labelled);classes_]];
acc_test = mean(classes_ == labels_organized(unlabelled));

end

%--------------------------------------------------------------------------
function [labels_organized, imno_organized, labelled, unlabelled,unlab_priors ] = create_mapping_for_ResNet(train_idx,val_idx,class,imno, priors)
%--------------------------------------------------------------------------
all_indices      = [train_idx; val_idx];
unlab_priors     = priors(all_indices,:);
labels_organized = class(all_indices);
imno_organized = imno(all_indices);

labelled         = (1:length(train_idx))';
unlabelled       = (length(train_idx) + 1 : length(train_idx) + length(val_idx))';
end
