% -------------------------------------------------------------------------
% Sinem Aslan
% Copyright 2019 Sinem Aslan.  [sinem.aslan-at-unive.it]
% Please email me if you have any questions.
%
% Please cite to these papers:
%
% [1] S. Aslan, S. Vascon, and M. Pelillo, 
% "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." 
% Pattern Recognition Letters (2019) (In Press).
%
% [2] S. Aslan, S. Vascon, M. Pelillo,
% Ancient coin classification using graph transduction games
% 2018 IEEE Int. Conf. on Metrology for Archaeology and Cultural Heritage (2018 (In Press))

%--------------------------------------------------------------------------
function main_RRC60
%--------------------------------------------------------------------------
clear all;
clc;

addpath('./utils');

coin_sides = {'O','R','B'};
param.dataFolder = './Data';

param.nr_classes = 60;
param.num_trials = 5;
param.set        = [1:10,15:5:20,30:10:80];
param.alphas     = 0.1:0.1:0.9;

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