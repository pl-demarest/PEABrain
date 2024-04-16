function regionsOut =  generateRegions(listSelectedRegions,listAllRegions,directory,projectionSide)



%get a list of compatible fieldnames for output struct

fns = matlab.lang.makeValidName(listSelectedRegions);

%get a list of regions that are not selected, this will be generate an
%object that will not be colored

otherRegions = setdiff(listAllRegions,listSelectedRegions);

% generate lists of files for whole brain, and brain subregions, then
%get a list for each. Identify the directory that should be used for the
%input list
cortexDir = directory(contains(directory,'MNIBrain'));
rHipDir = directory(contains(directory,'MNIRHip'));
lHipDir = directory(contains(directory,'MNILHip'));

%check to see which directory to use
load(cortexDir{1},"annotation")
matchingElements = all(ismember(listAllRegions(1:end-1),{annotation.AnnotationLabel.Name}));

    %initialize storage for electrodes within a named region
if matchingElements

inRegionElectrodes = [];

if ~ismember('None', listSelectedRegions)

for r = 1:length(listSelectedRegions) %

    pooledpts = [];
    pooledElectrodes = [];

    for f = 1:length(rHipDir)

    curr = load(cortexDir{f},"annotation","cortex","tala","electrodeDefinition");

    %Get identifier for the ID of the current region
    curRegionIDX = find(strcmpi({curr.annotation.AnnotationLabel.Name},listSelectedRegions{r}));
    ID = curr.annotation.AnnotationLabel(curRegionIDX).Identifier;

    switch projectionSide %project relevalnt points and electrodes to either left or curr hemisphere

        case 'left'
            %reflect electrodes on the right side to the left side, note
            %that the electrodes are the same across both data files, so
            %there shouldnt be any difference in the variables loaded.
            electrodes = curr.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)>0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            %do the same for the cortical points
            rpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 2),:);
            lpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 1),:);

            rpts(:,1) = - rpts(:,1);
            rpts(rpts(:,1)>0,1) = -rpts(rpts(:,1)>0,1);

        case 'right'

            %reflect electrodes on the left side to the right side
            electrodes = curr.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)<0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            rpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 2),:);
            lpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 1),:);

            lpts(:,1) = - lpts(:,1);
            lpts(lpts(:,1)<0,1) = -lpts(lpts(:,1)<0,1);

        case 'none'
            rpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 2),:);
            lpts = curr.cortex.vert(find(curr.annotation.Annotation == ID & curr.cortex.vertId == 1),:);
            electrodes = curr.tala.electrodes;
    end
    %pool points then resample to obtain "average" patient region set
    pts = [rpts;lpts];
    pc = pointCloud(pts);
    pds = pcdownsample(pc,'nonuniformGridSample',6);
    pds = pcdownsample(pds,'random',.5);

    pooledpts = [pooledpts;pds.Location];

    %find electrodes within this region

    eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), listSelectedRegions(r))), curr.electrodeDefinition.Label(:));
    electrodesTemp = electrodes(eIDX,:);

    pooledElectrodes = [pooledElectrodes;electrodesTemp];

    end

% resample pooled points 

pcAll = pointCloud(pooledpts);
pcOut = pcdownsample(pcAll,'nonuniformGridSample',6);
pcOut = pcdownsample(pcOut,'gridAverage',0.0001);

shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3));
a = criticalAlpha(shp,'one-region');
shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3),a);

[t,v] = boundaryFacets(shp);

regionsOut.regions.(fns{r}).tri = t;
regionsOut.regions.(fns{r}).vert = v;
regionsOut.regions.(fns{r}).electrodes = pooledElectrodes;

inRegionElectrodes = [inRegionElectrodes;pooledElectrodes];

end

end %check if no regions selected

%clear/initialize variable storage
    pooledpts = [];
    pooledElectrodes = [];

    for f = 1:length(rHipDir)

    curr = load(cortexDir{f},"annotation","cortex","tala","electrodeDefinition");

    %Get identifier for the ID of the current region
    curRegionIDX = find(ismember({curr.annotation.AnnotationLabel.Name},otherRegions));
    ID = [curr.annotation.AnnotationLabel(curRegionIDX).Identifier];

    switch projectionSide %project relevalnt points and electrodes to either left or right hemisphere

        case 'left'
            %reflect electrodes on the right side to the left side, note
            %that the electrodes are the same across both data files, so
            %there shouldnt be any difference in the variables loaded.
            electrodes = curr.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)>0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            %do the same for the cortical points
            rh = find(curr.cortex.vertId == 2);
            regions = ismember(curr.annotation.Annotation,ID);
            rIDX = getLogicalIndex(regions,rh);

            rpts = curr.cortex.vert(rIDX,:);

            lh = find(curr.cortex.vertId == 1);

            lIDX = getLogicalIndex(regions,lh);
            lpts = curr.cortex.vert(lIDX,:);

            rpts(:,1) = - rpts(:,1);
            rpts(rpts(:,1)>0,1) = -rpts(rpts(:,1)>0,1);

        case 'right'

            %reflect electrodes on the left side to the right side
            electrodes = curr.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)<0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            rh = find(curr.cortex.vertId == 2);
            regions = ismember(curr.annotation.Annotation,ID);
            rIDX = getLogicalIndex(regions,rh);

            rpts = curr.cortex.vert(rIDX,:);

            lh = find(curr.cortex.vertId == 1);
            lIDX = getLogicalIndex(regions,lh);
            lpts = curr.cortex.vert(lIDX,:);
            lpts(:,1) = - lpts(:,1);
            lpts(lpts(:,1)<0,1) = -lpts(lpts(:,1)<0,1);

        case 'none'
            rh = find(curr.cortex.vertId == 2);
            regions = ismember(curr.annotation.Annotation,ID);
            rIDX = getLogicalIndex(regions,rh);
            rpts = curr.cortex.vert(rIDX,:);

            lh = find(curr.cortex.vertId == 1);
            lIDX = getLogicalIndex(regions,lh);
            lpts = curr.cortex.vert(lIDX,:);
            electrodes = curr.tala.electrodes;
    end
    %pool points then resample to obtain "average" patient region set
    pts = [rpts;lpts];
    pc = pointCloud(pts);
    pds = pcdownsample(pc,'nonuniformGridSample',6);
    pds = pcdownsample(pds,'random',.5);

    pooledpts = [pooledpts;pds.Location];

    %find electrodes within this region

    eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), otherRegions)), curr.electrodeDefinition.Label(:));
    electrodesTemp = electrodes(eIDX,:);

    pooledElectrodes = [pooledElectrodes;electrodesTemp];

    end

% resample pooled points 

pcAll = pointCloud(pooledpts);
pcOut = pcdownsample(pcAll,'nonuniformGridSample',6);
pcOut = pcdownsample(pcOut,'gridAverage',0.0001);

shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3));
a = criticalAlpha(shp,'one-region');
shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3),a);

[t,v] = boundaryFacets(shp);

regionsOut.regions.otherRegions.tri = t;
regionsOut.regions.otherRegions.vert = v;
regionsOut.regions.otherRegions.electrodes = pooledElectrodes;

outRegionElectrodes = pooledElectrodes;

regionsOut.electrodes.inRegionElectrodes = inRegionElectrodes;
regionsOut.electrodes.outRegionElectrodes = outRegionElectrodes;
regionsOut.electrodes.all = [inRegionElectrodes; outRegionElectrodes];
end

%% For Hippocampus

load(rHipDir{1},"annotation")
matchingElements = all(ismember(listAllRegions(1:end-1),{annotation.AnnotationLabel.Name}));

if matchingElements

    %initialize storage for electrodes within a named region

inRegionElectrodes = [];

if ~ismember('None', listSelectedRegions) %check if no regions selected

for r = 1:length(listSelectedRegions) %

    pooledpts = [];
    pooledElectrodes = [];

    for f = 1:length(rHipDir)

    right = load(rHipDir{f},"annotation","cortex","tala","electrodeDefinition");
    left = load(lHipDir{f},"annotation","cortex","tala","electrodeDefinition");

    %Get identifier for the ID of the current region
    curRegionIDX = find(strcmpi({right.annotation.AnnotationLabel.Name},listSelectedRegions{r}));
    ID = right.annotation.AnnotationLabel(curRegionIDX).Identifier;

    switch projectionSide %project relevalnt points and electrodes to either left or right hemisphere

        case 'left'
            %reflect electrodes on the right side to the left side, note
            %that the electrodes are the same across both data files, so
            %there shouldnt be any difference in the variables loaded.
            electrodes = right.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)>0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            %do the same for the cortical points
            rpts = right.cortex.vert(find(right.annotation.Annotation == ID),:);
            lpts = left.cortex.vert(find(left.annotation.Annotation == ID),:);

            rpts(:,1) = - rpts(:,1);

        case 'right'

            %reflect electrodes on the left side to the right side
            electrodes = right.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)<0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            rpts = right.cortex.vert(find(right.annotation.Annotation == ID),:);
            lpts = left.cortex.vert(find(left.annotation.Annotation == ID),:);

            lpts(:,1) = - lpts(:,1);

        case 'none'
            rpts = right.cortex.vert(find(right.annotation.Annotation == ID),:);
            lpts = left.cortex.vert(find(left.annotation.Annotation == ID),:);
            electrodes = right.tala.electrodes;
    end
    %pool points then resample to obtain "average" patient region set
    pts = [rpts;lpts];
    pc = pointCloud(pts);
    pds = pcdownsample(pc,'nonuniformGridSample',6);
    pds = pcdownsample(pds,'random',.5);

    pooledpts = [pooledpts;pds.Location];

    %find electrodes within this region
    eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), listSelectedRegions(r))), right.electrodeDefinition.Label(:));
    electrodesTemp = electrodes(eIDX,:);
    clear electrodes
    pooledElectrodes = [pooledElectrodes;electrodesTemp];

    end

% resample pooled points 

pcAll = pointCloud(pooledpts);
pcOut = pcdownsample(pcAll,'nonuniformGridSample',6);
pcOut = pcdownsample(pcOut,'gridAverage',0.0001);

shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3));
a = criticalAlpha(shp,'one-region');
shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3),a);

[t,v] = boundaryFacets(shp);

regionsOut.regions.(fns{r}).tri = t;
regionsOut.regions.(fns{r}).vert = v;
regionsOut.regions.(fns{r}).electrodes = pooledElectrodes;

inRegionElectrodes = [inRegionElectrodes;pooledElectrodes];

end

end % check if no regions selected

%clear/initialize variable storage
    pooledpts = [];
    pooledElectrodes = [];

    for f = 1:length(rHipDir)

    right = load(rHipDir{f},"annotation","cortex","tala","electrodeDefinition");
    left = load(lHipDir{f},"annotation","cortex","tala","electrodeDefinition");

    %Get identifier for the ID of the current region
    curRegionIDX = find(ismember({right.annotation.AnnotationLabel.Name},otherRegions));
    ID = [right.annotation.AnnotationLabel(curRegionIDX).Identifier];

    switch projectionSide %project relevalnt points and electrodes to either left or right hemisphere

        case 'left'
            %reflect electrodes on the right side to the left side, note
            %that the electrodes are the same across both data files, so
            %there shouldnt be any difference in the variables loaded.
            electrodes = right.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)>0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            %do the same for the cortical points

            rpts = right.cortex.vert(ismember(right.annotation.Annotation, ID),:);
            lpts = left.cortex.vert(ismember(left.annotation.Annotation, ID),:);

            rpts(:,1) = - rpts(:,1);

        case 'right'

            %reflect electrodes on the left side to the right side
            electrodes = right.tala.electrodes;
            rightElectrodes = find(electrodes(:,1)<0);  
            electrodes(rightElectrodes,1) = -electrodes(rightElectrodes,1);

            rpts = right.cortex.vert(ismember(right.annotation.Annotation, ID),:);
            lpts = left.cortex.vert(ismember(left.annotation.Annotation, ID),:);

            lpts(:,1) = - lpts(:,1);

        case 'none'
            rpts = right.cortex.vert(ismember(right.annotation.Annotation, ID),:);
            lpts = left.cortex.vert(ismember(left.annotation.Annotation, ID),:);
            electrodes = right.tala.electrodes;
    end
    %pool points then resample to obtain "average" patient region set
    pts = [rpts;lpts];
    pc = pointCloud(pts);
    pds = pcdownsample(pc,'nonuniformGridSample',6);
    pds = pcdownsample(pds,'random',.5);

    pooledpts = [pooledpts;pds.Location];

    %find electrodes within this region
    eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), otherRegions)), right.electrodeDefinition.Label(:));
    electrodesTemp = electrodes(eIDX,:);
    clear electrodes
    pooledElectrodes = [pooledElectrodes;electrodesTemp];

    end

% resample pooled points 

pcAll = pointCloud(pooledpts);
pcOut = pcdownsample(pcAll,'gridAverage',0.0001);
pcOut = pcdownsample(pcOut,'gridAverage',0.0001);

shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3));
a = criticalAlpha(shp,'one-region');
shp = alphaShape(pcOut.Location(:,1),pcOut.Location(:,2),pcOut.Location(:,3),a);

[t,v] = boundaryFacets(shp);

regionsOut.regions.otherRegions.tri = t;
regionsOut.regions.otherRegions.vert = v;
regionsOut.regions.otherRegions.electrodes = pooledElectrodes;

outRegionElectrodes = pooledElectrodes;

regionsOut.electrodes.inRegionElectrodes = inRegionElectrodes;
regionsOut.electrodes.outRegionElectrodes = outRegionElectrodes;
regionsOut.electrodes.all = [inRegionElectrodes; outRegionElectrodes];

end
end