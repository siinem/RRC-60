% REPEAT ALL FOR EACH TRAINING SET:
% 1. get performance result for each ensemble.
% 2. select the ensemble feature giving highest performance
% 3. Get average of three priors and use it as the prior


%--------------------------------------------------------------------------
function exp_main_ensemble
%--------------------------------------------------------------------------
clear all; clc;

param.dir_result = './Data/Results/';
param.dir_split = './Data/Split_DS/';
param.dir_features = './Data/features_FineTuned_ResNet';
param.net_name = 'resnet152';
ss_set={'s1','s2'};
param.ver = 'vEnsemble';
param.nr_classes = 60;
param.num_nets = 3;
% param.set = [1:10,15:5:70];
param.set = [1:10,15:5:20,30:10:70];

need_preprop = 1;

for ss=1:2
    param.ds = cell2mat(ss_set(ss));
if need_preprop==1
    for n = 1:3
        preprocessing_for_ensemble(n,param.ds);
    end
end


path = define_paths(param);

acc_N_net = exp_N_NETs(param);
[acc_N_gtg_wo, acc_N_gtg_w] = exp_N_GTGs(param);
if ~exist(path.acc_N_net,'file'),    save(path.acc_N_net,'acc_N_net');       else load(path.acc_N_net,'acc_N_net');       end
if ~exist(path.acc_N_gtg_wo,'file'), save(path.acc_N_gtg_wo,'acc_N_gtg_wo'); else load(path.acc_N_gtg_wo,'acc_N_gtg_wo'); end
if ~exist(path.acc_N_gtg_w,'file'),  save(path.acc_N_gtg_w,'acc_N_gtg_w');   else load(path.acc_N_gtg_w,'acc_N_gtg_w');   end

print_result_for_LaTeX_Nnets(param,'ResNet',acc_N_net);
print_result_for_LaTeX_Nnets(param,'GTG w/o',acc_N_gtg_wo);
print_result_for_LaTeX_Nnets(param,'GTG w',acc_N_gtg_w);

% get mean and std of NETs and GTGs:
[mu_net,std_net] = func_mean_std_acc(acc_N_net);
[mu_gtg_wo,std_gtg_wo] = func_mean_std_acc(acc_N_gtg_wo);
[mu_gtg_w,std_gtg_w] = func_mean_std_acc(acc_N_gtg_w);

print_mean_std_for_LaTeX(param,'Avr ResNet',mu_net,std_net);
print_mean_std_for_LaTeX(param,'Avr GTG w/o',mu_gtg_wo,std_gtg_wo)
print_mean_std_for_LaTeX(param,'Avr GTG w',mu_gtg_w,std_gtg_w)


% PRIOR OF BEST FEATURES TO GTG:
[~,param.best_ens] = max(acc_N_net);
acc_net_BF = exp_NET_BestFeat(param);
[acc_gtg_wo_BF, acc_gtg_w_BF] = exp_GTG_BestFeat(param); % Best ResNet features and their priors 
if ~exist(path.acc_net_BF,'file'),    save(path.acc_net_BF,'acc_net_BF');       else load(path.acc_net_BF,'acc_net_BF');       end
if ~exist(path.acc_gtg_wo_BF,'file'), save(path.acc_gtg_wo_BF,'acc_gtg_wo_BF'); else load(path.acc_gtg_wo_BF,'acc_gtg_wo_BF'); end
if ~exist(path.acc_gtg_w_BF,'file'),  save(path.acc_gtg_w_BF,'acc_gtg_w_BF');   else load(path.acc_gtg_w_BF,'acc_gtg_w_BF');   end

print_result_for_LaTeX_1net(param,'ResNet(Best)',acc_net_BF)
print_result_for_LaTeX_1net(param,'GTG(Best) w/o',acc_gtg_wo_BF)
print_result_for_LaTeX_1net(param,'GTG(Best) w',acc_gtg_w_BF)


% ENSEMBLED PRIORS TO GTG
acc_net_ens = exp_NET_ensemble(param);
acc_gtg_w_ens = exp_GTG_BestFeat_ensemble(param); % Priors are ensembled in this experiment.
if ~exist(path.acc_net_ens,'file'),   save(path.acc_net_ens,'acc_net_ens');     else load(path.acc_net_ens,'acc_net_ens');     end
if ~exist(path.acc_gtg_w_ens,'file'), save(path.acc_gtg_w_ens,'acc_gtg_w_ens'); else load(path.acc_gtg_w_ens,'acc_gtg_w_ens'); end

print_result_for_LaTeX_1net(param,'ResNet(Ens)',acc_net_ens)
print_result_for_LaTeX_1net(param,'GTG(Ens) w',acc_gtg_w_ens)
end
end


