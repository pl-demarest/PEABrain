function cleanDataOut = getCleanData(signal,samplingRate,stimulationIndex,stimulationWindow)

hp_cutoff = 0.5;
order = 5;
type = 'high';
[b0_hp, a0_hp] = butter(order, 2*hp_cutoff/samplingRate, type);

hp_signal = filtfilt(b0_hp,a0_hp,double(signal))';

removeArtifactSignal = removeArtifact(hp_signal',stimulationIndex,stimulationWindow); %sitmulation window is in samples

cleanDataOut = multi_iirnotch_filtering(removeArtifactSignal,samplingRate,60); 

end
