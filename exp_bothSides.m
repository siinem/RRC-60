%-------------------------------------------------------------------------
% Classification accuracy of ResNet152 and GTG are computed using fused 
% information from both (B) sides of each coin. 
% 
% Two fusion schemes are applied for GTG:
% 1. Similarity fusion: convex combination of similarity matrices is
%    computed and GTG is implemented.
% 2. Feature concatenation: Similarity matrix of concatenated feature is
%    computed and GTG is implemented.
% 
% For each of the five train, val and test set splits performances of the
% methods are computed. Averaged performance of five trials with standard
% deviations are presented.
% 
%--------------------------------------------------------------------------
function exp_bothSides(param,path)
%--------------------------------------------------------------------------
allAccuracy_resnet    = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_wo    = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_w     = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_wo_fc = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_w_fc  = zeros(param.num_trials,length(param.set));

for trial_no = 1:param.num_trials
    
    if ~exist(sprintf(path.accuracy_fusion,char(param.side),num2str(trial_no)) ,'file')
        
                                accuracy.resnet = compute_ResNet_fusion(path,param,trial_no);
              [accuracy.gtg_wo, accuracy.gtg_w] = compute_GTG_fusion(path,param,trial_no);
        [accuracy.gtg_wo_fc, accuracy.gtg_w_fc] = compute_GTG_fusion_featConcat(path,param,trial_no);
        
        save(sprintf(path.accuracy_fusion,char(param.side),num2str(trial_no)),'accuracy');
    else
        load(sprintf(path.accuracy_fusion,char(param.side),num2str(trial_no)),'accuracy');
    end
    
    allAccuracy_resnet    (trial_no,:) = accuracy.resnet;
    allAccuracy_gtg_wo    (trial_no,:) = accuracy.gtg_wo;
    allAccuracy_gtg_w     (trial_no,:) = accuracy.gtg_w;
    allAccuracy_gtg_wo_fc (trial_no,:) = accuracy.gtg_wo_fc;
    allAccuracy_gtg_w_fc  (trial_no,:) = accuracy.gtg_w_fc;
end

[accuracy_all.mu_resnet,    accuracy_all.std_resnet]    = mean_std_acc(allAccuracy_resnet);
[accuracy_all.mu_gtg_wo,    accuracy_all.std_gtg_wo]    = mean_std_acc(allAccuracy_gtg_wo);
[accuracy_all.mu_gtg_w ,    accuracy_all.std_gtg_w ]    = mean_std_acc(allAccuracy_gtg_w);
[accuracy_all.mu_gtg_wo_fc, accuracy_all.std_gtg_wo_fc] = mean_std_acc(allAccuracy_gtg_wo_fc);
[accuracy_all.mu_gtg_w_fc , accuracy_all.std_gtg_w_fc ] = mean_std_acc(allAccuracy_gtg_w_fc);

 
save(sprintf(path.accuracy_all_fusion,char(param.side)),'accuracy_all');

end


function [mu_,std_] = mean_std_acc(acc_list)
mu_  = mean(acc_list,1);
std_ = std(acc_list,[],1);
end

