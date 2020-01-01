
function path = define_paths(dir_data)

path.load_split    = [char(dir_data),'/Split/split_trial_%s_numlabeled_%s.mat'];      
path.load_priors   = [char(dir_data),'/Priors/priors_side_%s_trial_%s_numlabeled_%s.mat'];
path.load_features = [char(dir_data),'/Features/features_side_%s_trial_%s_numlabeled_%s.mat'];

path.accuracy = [char(dir_data),'/Results/accuracy_side_%s_trial_%s.mat'];      
path.accuracy_all = [char(dir_data),'/Results/accuracy_side_%s_all.mat'];   

path.accuracy_fusion = [char(dir_data),'/Results/accuracy_side_%s_trial_%s.mat'];      
path.accuracy_all_fusion = [char(dir_data),'/Results/accuracy_side_%s_all.mat'];   

end