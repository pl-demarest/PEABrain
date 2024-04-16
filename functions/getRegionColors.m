function colors = getRegionColors(structNames,regionNames,regionColors)

regions = ismember(regionNames,structNames);
colors = regionColors(regions,:);

end