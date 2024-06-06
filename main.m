clear
close all
addpath(genpath(cd))

%% initialize data directory and variables

dataDirectory = 'data/models/';
files = dir(dataDirectory);
dirFlags = [files.isdir];
models = sort({files(3:end).name});

%%

load('listCort.mat');
load('colorlookup.mat')

projectSide = 'none'; %specify which side the region should be reflected to. If 'left', then the right hemisphere region will be flipped

%% cortex

cortStructuresIDX = listdlg('PromptString',{'Select brain regions to average and project'},'ListString',listCort);
cortStructures = listCort(cortStructuresIDX);

%%
cortOut = generateRegions(cortStructures,listCort,models,projectSide);

%% 

figure;

colors = getRegionColors(cortStructures,colorTableName,colorTableColor);
cort = plotProjectedRegions(cortOut,[0.5,0.5,0.5],[0,0,0],.5,'FaceAlpha',0.03);

