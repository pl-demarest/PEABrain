%% Demo Extraction of Brain Regions from VERA database
clear all
close all
addpath(genpath(cd))
%% Show whole Structure
% the region extractor can be used to extract surfaces from any single
% subject, as long as they have a MNI VERA struct for at least the cortex,
% and the hippocampus.

%The output struct will contain at least a surface structure of the cortex,
%the amygdala, and the hippocampus. When callling the function, a list will
%appear. Select all additional regions you would like to extract (to select multiple regions, use command on mac, ctrl on PC). They will
%appear as individual subfields in the output struct. Each region will
%contain a "vert" field, which contains the vertices (points) of the region
%surface, a "tri" field, which contains the contextivity matrix for all of
%the vertices, and the "electrodes" field, wich will contain all electrodes
%within that region.


out = singleRegionExtractor('BJH042');

%%

%These structs can be passed to the plotProjectedRegions function. This
%function requies the user to specify a list of colors. The list of colors
%should be an n x 3 matrix (RGB) with n corresponding to the number of
%subfields in the output struct. 

% note that the colors can be initialized, and after calling the
% "plotProjectedRegions" function, individual colors/alpha of surfaces can
% be adjusted through indexing.


%colors can be specified by any method, the number of colors should be at
%least the number 
surfColors = [.6,0,0;
    0,0,.8;
    .5,.5,.5;
    .5,.5,0;
    0,0.5,0.5];

%Colors of the electrodes can also be specified. Here, I will make all
%electrodes other than the ones contained in the "cortexOther" struct field
%red, and the rest black.

eColors = [1,0,0;
    1,0,0;
    0,0,0; % "cortexOther"
    1,0,0;
    1,0,0];

figure;
[surface] = plotProjectedRegions(out,surfColors,eColors,1); %where 1 is the default radius of the electrodes, if no effect size is specified

%%
%Now we can adjust each surface as needed. Note that each index corresponds
%to the fieldname of the out struct

for s = 1:length(surface)

    surface(s).FaceAlpha = 0.3;

end

%%
%The cortex is a bit too dark, we know that the grey cortex is the 3rd
%index of the out struct "cortexOther" so we can decrease the alpha of the
%3rd surface

surface(3).FaceAlpha = 0.1;
%%
% By using the "getOneSide" function, one can extract only the left or
% right side of an output struct above. Note that this does not project the
% surface or the electrodes to one side, but only shows on side. You can
% specify "left" or "right" depending on the side you would like. 
right = getOneSide(out,'left');

%visualize as with before:
figure;
[surface2] = plotProjectedRegions(right,surfColors,eColors,1); %where 1 is the radius of the electrodes
surface2(3).FaceAlpha = 0.1;

%%
% a Feature still in development is to visualize the effect size at each
% electrode to correspond to the radius. The functionality is written,
% however the pipelilne to include this data in the extracted struct
% variables is still in development:

%we can randomly generate a set of effect sizes. Note, the visualization
%will scale anything <0.5 to 0.5, and anything >4 to 4 for the radius. 

effectLength = length(out.regions.cortexOther.electrodes);
ranEffect = 0.5+(0.5+4)*rand(effectLength,1);

%specify the effect size as a struct within the region named "effectSize"

out.regions.cortexOther.effectSize = ranEffect;

% visualize

figure;
[surface] = plotProjectedRegions(out,surfColors,eColors,1,'FaceAlpha',0.4); %where 1 is the default radius of the electrodes, if no effect size is specified

surface(3).FaceAlpha = 0.1;

%%

%we the plot function is also capable of using colormaps corresponding to
%the effect size of each electrode. 

%here, we normalize the above generated effect sizes, and then map them to
%a colormap
cmap = colormap("copper");
data = ranEffect;
% Normalize the data to [0, 1] for colormap indexing
normalizedData = (data - min(data)) / (max(data) - min(data));
% Number of colors in the colormap
numColors = size(cmap, 1);
% Map the normalized data to colormap indices
colorIndices = ceil(normalizedData * numColors);
colorIndices(colorIndices < 1) = 1;  % Ensure indices are within the valid range
rgbArray = cmap(colorIndices, :);

% now we can set the generated array to our output struct with the
% fieldname "effectColor" and visualize

out.regions.cortexOther.effectColor = rgbArray;

figure;
[surface] = plotProjectedRegions(out,surfColors,eColors,1,'FaceAlpha',0.4); %where 1 is the default radius of the electrodes, if no effect size is specified

surface(3).FaceAlpha = 0.1;


