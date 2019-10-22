%--------------------------------------------------------------------------
function [acc_N_gtg_WO, acc_N_gtg_W] = exp_N_GTGs(param)
%--------------------------------------------------------------------------

dir_split = param.dir_split;
dir_features = param.dir_features;
ver = param.ver;
ds = param.ds;
net_name = param.net_name;
num_nets = param.num_nets;
set = param.set;
nr_classes=param.nr_classes;

for i=1:length(set)
    for n = 1:num_nets
        % Path definitions to load data from
        path_load_split = fullfile(dir_split,char(ver), ['splitVect_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_', num2str(n), '.mat']);
        path_load_priors = fullfile(dir_features,['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_',num2str(n),'_priors.mat']);
        path_load_features = fullfile(dir_features, ['Sinem_',char(ver)],[char(net_name),'_',char(ds),'_FinTun_tr_',num2str(set(i)),'_ens_',num2str(n),'_features.mat']);
        % Load data
        load(path_load_features,'features');
        load(path_load_split,'split','class');
        load(path_load_priors,'priors');
        
        % Standadize  the features
        tr_mean = repmat(mean(features((split == 1),:),1), [size(features,1),1]);
        tr_std = repmat(std(features((split == 1),:),[],1), [size(features,1),1]);
        features = (features - tr_mean)./tr_std;
        W = compute_similarity(features,8);
        
        % Performance of GTG withOUT Prior
        W_prior = 0;
        acc_N_gtg_WO(n,i) = run_gtg(W, split, class, nr_classes, priors, W_prior);
        %             disp(['ENSEMBLE ',num2str(n),' GTG WITHOUT PRIORS - labelled/class: ', num2str(set(i)),' --- accuracy:',num2str(gtg_WO_acc_test_ens(n,i))])
        
        % Performance of GTG with Prior
        W_prior = 1;
        acc_N_gtg_W(n,i) = run_gtg(W,split,class,nr_classes,priors,W_prior);
        %             disp(['ENSEMBLE ',num2str(n),' GTG WITH PRIORS - labelled/class: ', num2str(set(i)),' --- accuracy:',num2str(gtg_W_acc_test_ens(n,i))])
        
    end
end

end

%--------------------------------------------------------------------------
function W = compute_similarity(features,nn)
%--------------------------------------------------------------------------
D = pdist(features,'euclidean');
D = squareform(D);
[V]=sort(D,2) + 1e-16;
T=V(:,nn);
sigmas=T*T';
W = exp(-(D.*D)./sigmas);
W = W .*not(eye(size(W)));
end


%--------------------------------------------------------------------------
function acc_test = run_gtg(W, split, class, nr_classes, priors, use_P)
%--------------------------------------------------------------------------

% prepare the matrix W
train_idx = find(split==1);
test_idx = find(split==3);
[W_organized, labels_organized, labelled, unlabelled, unlab_priors ] = create_mapping(W, train_idx, test_idx, class, priors);

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
acc_test = mean(HC(unlabelled) == labels_organized(unlabelled));
end



%--------------------------------------------------------------------------
function [W_organized, labels_organized, labelled, unlabelled,unlab_priors ] = create_mapping(W,train_idx,val_idx,class,priors)
%--------------------------------------------------------------------------
all_indices = [train_idx;val_idx];
W_organized = W(all_indices,all_indices);
unlab_priors = priors(all_indices,:);
labels_organized = class(all_indices);

labelled = (1:length(train_idx))';
unlabelled = (length(train_idx) + 1 : length(train_idx) + length(val_idx))';
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