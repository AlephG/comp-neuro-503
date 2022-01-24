function binSeq = spikeTrainBin(spiketimes,timeaxis,timestep)
     ind = round(spiketimes./timestep);
     numBins = round(timeaxis(end)/timestep);
     binSeq = zeros(1,numBins); % Set to zero
     binSeq(ind) = 1; % Record 1 if spike occured within a time step, 0 if not
     %display(length(find(binSeq == 1))/numBins); % To check the percentage of spikes over the time course
end