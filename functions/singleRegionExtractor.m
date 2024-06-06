function [out] = singleRegionExtractor(subject)

%initialize Lists
load('listHip.mat');
load('listCort.mat');
load('listAmyg.mat');
list = [listCort',listHip,listAmyg];
IDX = listdlg('PromptString',{'Select brain regions to visualize'},'ListString',list);
structures = list(IDX);
%% create separate indexes for cortex, hippocampus, and other

%load Data Files
cortex = load([subject '_APARC2009_MNIBrain.mat']);
cortexList = structures(ismember(structures,listCort));
cortexOther = setdiff(listCort,structures);


rHip = load([subject '_MNIRHip.mat']);
lHip = load([subject '_MNILHip.mat']);
amygList = structures(ismember(structures,listAmyg));
amygOther = setdiff(listAmyg,structures);
hipList = structures(ismember(structures,listHip));
hipOther = setdiff(listHip,structures);

%% iterate through list of structures, first determininng if cortex, amygdala, or hipp

%% cortex first
if ~isempty(cortexList)

    for s = 1:length(cortexList)
        %initialize index for region
        curStructure = cortexList(s);
        structName = formatForFieldname(curStructure);
        curRegionIDX = find(strcmpi({cortex.annotation.AnnotationLabel.Name},curStructure));
        ID = cortex.annotation.AnnotationLabel(curRegionIDX).Identifier;
        idx = find(cortex.annotation.Annotation == ID);
        [out.regions.(structName{:}).vert, out.regions.(structName{:}).tri] = extractSurface(idx,cortex.cortex.vert,cortex.cortex.tri);
        eLabels = cellfun(@(x) x{1}, cortex.electrodeDefinition.Label, 'UniformOutput', false);
        eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), curStructure)), eLabels(:));
        out.regions.(structName{:}).electrodes = cortex.tala.electrodes(eIDX,:);
    end

end

if ~isempty(cortexOther)
    curRegionIDX = find(ismember({cortex.annotation.AnnotationLabel.Name},cortexOther));
    ID = [cortex.annotation.AnnotationLabel(curRegionIDX).Identifier];
    idx = ismember(cortex.annotation.Annotation,ID);
    idx = find(idx == 1);
    [out.regions.cortexOther.vert, out.regions.cortexOther.tri] = extractSurface(idx,cortex.cortex.vert,cortex.cortex.tri);
    eLabels = cellfun(@(x) x{1}, cortex.electrodeDefinition.Label, 'UniformOutput', false);
    eIDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), cortexOther)), eLabels(:));
    out.regions.cortexOther.electrodes = cortex.tala.electrodes(eIDX,:);
end

%% amygdala second 
if ~isempty(amygList)
    for s = 1:length(amygList)
        %initialize index for region
        curStructure = amygList(s);
        structName = formatForFieldname(curStructure);
        curRegionIDX = find(strcmpi({rHip.annotation.AnnotationLabel.Name},curStructure));
        ID = rHip.annotation.AnnotationLabel(curRegionIDX).Identifier;

        ridx = find(rHip.annotation.Annotation == ID);
        [rP, rT] = extractSurface(ridx,rHip.cortex.vert,rHip.cortex.tri);

        lidx = find(lHip.annotation.Annotation == ID);
        [lP, lT] = extractSurface(lidx,lHip.cortex.vert,lHip.cortex.tri);

        lT = lT + length(rP); %adjust for length of first point set

        out.regions.(structName{:}).vert = [rP;lP];
        out.regions.(structName{:}).tri = [rT;lT];

        eLabels = cellfun(@(x) x{1}, rHip.electrodeDefinition.Label, 'UniformOutput', false);
        IDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), curStructure)), eLabels(:));
        out.regions.(structName{:}).electrodes = cortex.tala.electrodes(find(IDX),:);
    end

end

if ~isempty(amygOther)

        curRegionIDX = find(ismember({rHip.annotation.AnnotationLabel.Name},amygOther));
        ID = [rHip.annotation.AnnotationLabel(curRegionIDX).Identifier];

        ridx = ismember(rHip.annotation.Annotation,ID);
        ridx = find(ridx == 1);
        [rP, rT] = extractSurface(ridx,rHip.cortex.vert,rHip.cortex.tri);

        lidx = ismember(lHip.annotation.Annotation,ID);
        lidx = find(lidx == 1);
        [lP, lT] = extractSurface(lidx,lHip.cortex.vert,lHip.cortex.tri);

        lT = lT + length(rP); %adjust for length of first point set

        out.regions.amygOther.vert = [rP;lP];
        out.regions.amygOther.tri = [rT;lT];
        
        eLabels = cellfun(@(x) x{1}, rHip.electrodeDefinition.Label, 'UniformOutput', false);
        IDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), amygOther)), eLabels(:));
        out.regions.amygOther.electrodes = rHip.tala.electrodes(find(IDX),:);


end

%% hippocampus third
if ~isempty(hipList)
    for s = 1:length(hipList)
        %initialize index for region
        curStructure = hipList(s);
        structName = formatForFieldname(curStructure);
        curRegionIDX = find(strcmpi({rHip.annotation.AnnotationLabel.Name},curStructure));
        ID = rHip.annotation.AnnotationLabel(curRegionIDX).Identifier;

        ridx = find(rHip.annotation.Annotation == ID);
        [rP, rT] = extractSurface(ridx,rHip.cortex.vert,rHip.cortex.tri);

        lidx = find(lHip.annotation.Annotation == ID);
        [lP, lT] = extractSurface(lidx,lHip.cortex.vert,lHip.cortex.tri);

        lT = lT + length(rP); %adjust for length of first point set

        out.regions.(structName{:}).vert = [rP;lP];
        out.regions.(structName{:}).tri = [rT;lT];
        eLabels = cellfun(@(x) x{1}, rHip.electrodeDefinition.Label, 'UniformOutput', false);
        IDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), curStructure)), eLabels(:));
        out.regions.(structName{:}).electrodes = cortex.tala.electrodes(find(IDX),:);
    end

end

if ~isempty(hipOther)

        curRegionIDX = find(ismember({rHip.annotation.AnnotationLabel.Name},hipOther));
        ID = [rHip.annotation.AnnotationLabel(curRegionIDX).Identifier];

        ridx = ismember(rHip.annotation.Annotation,ID);
        ridx = find(ridx == 1);
        [rP, rT] = extractSurface(ridx,rHip.cortex.vert,rHip.cortex.tri);

        lidx = ismember(lHip.annotation.Annotation,ID);
        lidx = find(lidx == 1);
        [lP, lT] = extractSurface(lidx,lHip.cortex.vert,lHip.cortex.tri);

        lT = lT + length(rP); %adjust for length of first point set

        out.regions.hipOther.vert = [rP;lP];
        out.regions.hipOther.tri = [rT;lT];
        eLabels = cellfun(@(x) x{1}, rHip.electrodeDefinition.Label, 'UniformOutput', false);
        IDX = cellfun(@(x) any(cellfun(@(y) contains(x, y), hipOther)), eLabels(:));
        out.regions.hipOther.electrodes = cortex.tala.electrodes(find(IDX),:);

end

end