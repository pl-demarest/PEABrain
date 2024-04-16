function idx = getLogicalIndex(logicalArray,index)

idx = false(size(logicalArray));

idx(index) = logicalArray(index);

end