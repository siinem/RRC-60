
function acc_net_ens = exp_NET_ensemble(param)

dir_split = param.dir_split;
dir_features = param.dir_features;
ver = param.ver;
ds = param.ds;
net_name = param.net_name;
num_nets = param.num_nets;
set = param.set;
nr_classes=param.nr_classes;
best_ens = param.best_ens;


for i=1:length(set)
    
    % load split of best net:
    path_load_split = fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_', num2str(best_ens(i)), '.mat']);
    load(path_load_split,'split','class');


    ens_pr = load(fullfile(dir_features,['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_1_priors.mat']),'priors');
    ens_priors{1} = ens_pr.priors;    
    
    ens_spl = load(fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_1.mat']),'imno','class');
    ens_split{1} =  [ens_spl.class,ens_spl.imno];
    
    ens_pr = load(fullfile(dir_features,['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_2_priors.mat']),'priors');
    ens_priors{2} = ens_pr.priors;
    
    ens_spl = load(fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_2.mat']),'imno','class');
    ens_split{2} = [ens_spl.class,ens_spl.imno];
    
    ens_pr = load(fullfile(dir_features,['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_3_priors.mat']),'priors');
    ens_priors{3} = ens_pr.priors;
    
    ens_spl = load(fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_3.mat']),'imno','class');
    ens_split{3} = [ens_spl.class,ens_spl.imno];
    
    clear ens_spl;     clear ens_pr;
    
    priors = compute_ensembled_priors (ens_priors,ens_split,best_ens,i);
    acc_net_ens(i) = perf_net(split,class,nr_classes,priors);
%     disp(['GTG WITH ENSEMBLED PRIORS - labelled/class: ', num2str(set(i)),' --- accuracy:',num2str(gtg_W_Ens_acc_test(i))])
end

end



function priors = compute_ensembled_priors (ens_priors,ens_split,best_ens,i)


ens_set = setdiff(1:3,best_ens(i));
s1 = ens_split{best_ens(i)};
total_priors = ens_priors{best_ens(i)};


for t=1:length(ens_set)
    priors = [];
    s2 = ens_split{ens_set(t)};
    for s = 1:size(s1,1)
        [~,~,idx] = intersect(s1(s,:),s2,'rows');
        priors(s,:) = ens_priors{ens_set(t)}(idx,:);
    end
    total_priors = total_priors + priors;
end
priors = total_priors/3;
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




