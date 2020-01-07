% -------------------------------------------------------------------------
% Sinem Aslan
% Copyright 2019 Sinem Aslan.  [sinem.aslan-at-unive.it]
% Please email me if you have any questions.
%
% Please cite to:
%
% S. Aslan, S. Vascon, and M. Pelillo, 
% "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." 
% Pattern Recognition Letters (2019) (In Press).


%--------------------------------------------------------------------------
function main_RRC60
%--------------------------------------------------------------------------
clear all;
clc;

addpath('./utils');

coin_sides = {'O','R','B'}; % O: Observe; R: Reverse; B: Both
param.dataFolder = './Data';

param.nr_classes = 60; % Number of coin classes
param.num_trials = 5;  % Experiments are repeated for 5 trials, mean and std of all trials are presented.
param.set        = [1:10,15:5:20,30:10:80]; % Number of labeled images per class
param.alphas     = 0.1:0.1:0.9; % the range where alpha, the convex combination parameter, is tuned 

path = define_paths(param.dataFolder);

for i = 1:length(coin_sides)
    if strcmp(coin_sides{i},'B')
        param.side = coin_sides{i};
        exp_bothSides( param, path );
    else
        param.side = coin_sides{i};
        exp_singleSide( param, path );
    end
end

end
