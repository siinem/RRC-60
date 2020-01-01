
%-------------------------------------------------------------------------
% Classification accuracy of ResNet152 is computed for each training set 
% in increased sizes. Estimated class labels are decided regarding to max(softmax) 
% 
% priors: softmax output of ResNet152 when it is initialized by ImageNet 
%         and the whole network is finetuned by the training set consists of 
%         [number of labeled images per class] * 60 (classes) number of
%         images.
%
% split: shows the training (split = 1), validation (split = 2) and 
%        test (split = 3) set split
%
% ---------------------------------------------------------------------
function acc_resnet = compute_ResNet(path,param,trial_no)
% ---------------------------------------------------------------------

acc_resnet = zeros(1,length(param.set));

disp(['TRIAL ', num2str(trial_no)]);

for tr_no = 1:length(param.set)

    load(sprintf(path.load_split,num2str(trial_no),num2str(param.set(tr_no))),'split','class','imno');       
    load(sprintf(path.load_priors,param.side,num2str(trial_no),num2str(param.set(tr_no))) ,'priors');
    
    [ ~ , acc_resnet(tr_no)] = perf_net(split,class,imno,param.nr_classes,priors);
    
    disp(['RESNET - labelled img/class: ', num2str(param.set(tr_no)),' --- accuracy:',num2str(acc_resnet(tr_no))])
end


end
%--------------------------------------------------------------------------
function [labeling_info, acc_test] = perf_net(split,class,imno,nr_classes,priors)
%--------------------------------------------------------------------------
% select the labeled (training) samples [split = 1] and 
% unlabelled (test) samples [split = 3]

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



