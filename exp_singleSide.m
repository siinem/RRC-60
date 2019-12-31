%-------------------------------------------------------------------------
% Classification accuracy of ResNet152 and GTG are computed using images 
% from one side, i.e. Observe (O) or Reverse (R), of coins.
% 
% For each method, averaged performances of five trials (randomly sampled 
% train, val and test set splits) with the standard deviation are presented.
% 
%--------------------------------------------------------------------------
function exp_singleSide(param,path)
%--------------------------------------------------------------------------
allAccuracy_resnet    = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_wo    = zeros(param.num_trials,length(param.set));
allAccuracy_gtg_w     = zeros(param.num_trials,length(param.set));

for trial_no = 1:param.num_trials
    
    if ~exist(sprintf(path.accuracy,char(param.side),num2str(trial_no)) ,'file')
        
                          accuracy.resnet = compute_ResNet(path,param,trial_no);
        [accuracy.gtg_wo, accuracy.gtg_w] =    compute_GTG(path,param,trial_no);
        
        save(sprintf(path.accuracy,char(param.side),num2str(trial_no)),'accuracy');
    else
        load(sprintf(path.accuracy,char(param.side),num2str(trial_no)),'accuracy');
    end
    
    allAccuracy_resnet (trial_no,:) = accuracy.resnet;
    allAccuracy_gtg_wo (trial_no,:) = accuracy.gtg_wo;
    allAccuracy_gtg_w  (trial_no,:) = accuracy.gtg_w;
    
end

[accuracy_all.mu_resnet, accuracy_all.std_resnet] = mean_std_acc(allAccuracy_resnet);
[accuracy_all.mu_gtg_wo, accuracy_all.std_gtg_wo] = mean_std_acc(allAccuracy_gtg_wo);
[accuracy_all.mu_gtg_w , accuracy_all.std_gtg_w ] = mean_std_acc(allAccuracy_gtg_w);

save(sprintf(path.accuracy_all,char(param.side)),'accuracy_all');

end


function [mu_,std_] = mean_std_acc(acc_list)
mu_  = mean(acc_list,1);
std_ = std(acc_list,[],1);
end

