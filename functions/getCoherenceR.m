function [coherenceStruct]=getCoherenceR(data,f_corr,baselineWindow,taskWindow)
%Inpout should be ch x sig x trial
%return a matrix containing coherence values for each channel pair across
%all posisble trail combinations

%establish field names



states = {'baseline','task'};
stateWindows = {baselineWindow, taskWindow};
f = waitbar(0);

maxWaitbar = size(data,1)*size(data,1);
waitbarCount = 1;
for state = 1:length(states)

currentState = states{state};
currentStateWindow = stateWindows{state};


n = size(data,3);
N=n^2;
coherenceMatrix = nan(size(data,1),size(data,1),N);
%use this to generate all possible cmbinations of trials
[p, q] = meshgrid(1:n, 1:n);
mask   = triu(ones(n), 1) > 0.5;
pairs  = [p(mask) q(mask)];


for ch1 = 1:size(data,1)
    for ch2 = 1:size(data,1)

channel1 = squeeze(data(ch1,:,:));
channel2 = squeeze(data(ch2,:,:));



%initialize Correlation distribution
corrDistribution = nan(1,N);


parfor trialPair=1:N
    x = channel1(currentStateWindow,pairs(trialPair,1));
    y = channel2(currentStateWindow,pairs(trialPair,2));
    corrDistribution(trialPair)=f_corr(x,y);
end


coherenceMatrix(ch1,ch2,:) = corrDistribution;

waitbarCount = waitbarCount + 1;

waitbar(waitbarCount/maxWaitbar,f,['Done with channel ' num2str(ch1) 'x channel ' num2str(ch2)]);

    end %second Chan

end %first Chan

coherenceStruct.(currentState) = coherenceMatrix;





end %experimental state
close(f)
end