
function acc_N_net = exp_N_NETs(param)
dir_split = param.dir_split;
dir_features = param.dir_features;
ver = param.ver;
ds = param.ds;
net_name = param.net_name;
num_nets = param.num_nets;
set = param.set;
nr_classes = param.nr_classes;

for i=1:length(set)
    for n = 1:num_nets
        % Path definitions to load data from
        path_load_split = fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_', num2str(n), '.mat']);
        path_load_priors = fullfile(dir_features,['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_',num2str(n),'_priors.mat']);
        % Load data
        load(path_load_split,'split','class');
        load(path_load_priors,'priors');
        
        % Performance of ResNet
        acc_N_net(n,i) = perf_net(split,class,nr_classes,priors);
        %             disp(['RESNET - labelled/class: ', num2str(set(i)),' --- accuracy:',num2str(resnet_acc_test(n,i))])
        
              
    end
end
end

%--------------------------------------------------------------------------
function acc_test = perf_net(split,class,nr_classes,priors)
%--------------------------------------------------------------------------
% prepare the matrix W
train_idx = find(split==1);
test_idx = find(split==3);
[labels_organized, labelled, unlabelled, unlab_priors ] = create_mapping_for_ResNet(train_idx, test_idx, class, priors);

P = zeros(length(labels_organized),nr_classes);
[cl, ~] = grp2idx(labels_organized(labelled));

P(labelled, :) = full(ind2vec(cl'))';
P(unlabelled, :) = unlab_priors(unlabelled,:);
[~, BB ] = max(P(unlabelled,:),[],2);
acc_test = mean(BB == labels_organized(unlabelled));
end


%--------------------------------------------------------------------------
function [labels_organized, labelled, unlabelled,unlab_priors ] = create_mapping_for_ResNet(train_idx,val_idx,class,priors)
%--------------------------------------------------------------------------
all_indices = [train_idx;val_idx];
unlab_priors = priors(all_indices,:);
labels_organized = class(all_indices);

labelled = (1:length(train_idx))';
unlabelled = (length(train_idx) + 1 : length(train_idx) + length(val_idx))';
end



