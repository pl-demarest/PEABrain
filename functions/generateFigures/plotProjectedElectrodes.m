function surf = plotProjectedElectrodes(structIn,radius)

regionFNS = fieldnames(structIn.regions);

for f = 1:length(regionFNS)

    curRegion = regionFNS(f);

    t = structIn.regions.(curRegion{:}).tri;
    v = structIn.regions.(curRegion{:}).vert;
    e = structIn.regions.(curRegion{:}).electrodes;
    ec = [1,0,0];
    
    if strcmp(curRegion,'otherRegions')
    c = [0,0,0];
    ec = [0,0,0];
    end

    
    ax = gca;
    

end

end