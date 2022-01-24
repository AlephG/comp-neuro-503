%% 3b) Neurometric Analysis: ROC function
function area = ROC(before, after)
    nbTrials = sum(before);  % Number of trials for before (or failed trials)
    naTrials = sum(after); % Number of trials for after (or successful trials)
    criteria = [0:8];   % Array of criterion values
    
    % Calculate the coordinate in ROC curve for each criterion
    for i = 1:length(criteria)
        criterion = criteria(i);
        pHit(i) = sum(after((criterion+1):length(after)))/naTrials;
        pFalse(i) = sum(before((criterion+1):length(before)))/nbTrials;
    end
    
    area = trapz(flip(pFalse), flip(pHit));