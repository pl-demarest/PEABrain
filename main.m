clear
close all
addpath(genpath(cd))

%% initialize data directory and variables

dataDirectory = 'data/models/';
files = dir(dataDirectory);
dirFlags = [files.isdir];
models = sort({files(9:end).name});

%%

load('listHip.mat');
load('listCort.mat');
load('listAmyg.mat');
load('colorlookup.mat')

projectSide = 'left'; %specify which side the region should be reflected to. If 'left', then the right hemisphere region will be flipped

%%
amygStructuresIDX = listdlg('PromptString',{'Select amyg/hippocampus brain regions to average and project'},'ListString',listAmyg);
amygStructures = listAmyg(amygStructuresIDX);

%% amygdala

amygOut = generateRegions(amygStructures,listAmyg,models,projectSide);

%% hippocampus

hipStructuresIDX = listdlg('PromptString',{'Select amyg/hippocampus brain regions to average and project'},'ListString',listHip);
hipStructures = listHip(hipStructuresIDX);

%%
hippOut = generateRegions(hipStructures,listHip,models,projectSide);

%% cortex

cortStructuresIDX = listdlg('PromptString',{'Select brain regions to average and project'},'ListString',listCort);
cortStructures = listCort(cortStructuresIDX);

%%
cortOut = generateRegions(cortStructures,listCort,models,projectSide);

%% 
colors = getRegionColors(amygStructures,colorTableName,colorTableColor);

figure;
a = plotProjectedRegions(amygOut,colors,.5,'FaceAlpha',0.3);
hold on

for i = 1:length(a)

a(i).FaceColor = [0,1,0];

end

hip = plotProjectedRegions(hippOut,colors,.5,'FaceAlpha',0.5);
hip.FaceColor = [0,0,1];
hold on

colors = getRegionColors(cortStructures,colorTableName,colorTableColor);
cort = plotProjectedRegions(cortOut,colors,.5,'FaceAlpha',0.3);

cort(2).FaceColor = [0,1,1];