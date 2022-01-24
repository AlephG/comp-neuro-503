% Student ID: 260807111

% Load the data
load('decodingLabData.mat');

% Verify figure 
%labHandOutFigure;
%% 3 ROC Neurometric Analysis
% a) Histogram
beforeStim_1 = neuron1(:, 400:499);
afterStim_1 = neuron1(:, 540:639);
beforeStim_2 = neuron2(:, 400:499);
afterStim_2 = neuron2(:, 540:639); 



N1_0 = figure(1);
histBeforeN1 = hist(sum(beforeStim_1, 2), 0:8);
histAfterN1 = hist(sum(afterStim_1, 2), 0:8);
bar(0:8, [histBeforeN1;histAfterN1]');
title('Neuron 1') ;
xlabel('Spikes/100ms');
ylabel('Number of trials');
legend('Before motion stimulus', 'After motion stimulus');
saveas(N1_0,'HistN1-0.jpg');

N2_0 = figure(2);
histBeforeN2 = hist(sum(beforeStim_2, 2), 0:8);
histAfterN2 = hist(sum(afterStim_2, 2), 0:8);
bar(0:8, [histBeforeN2;histAfterN2]');
title('Neuron 2');
xlabel('Spikes/100ms')
ylabel('Number of trials')
legend('Before motion stimulus', 'After motion stimulus');
saveas(N2_0,'HistN2-0.jpg');

% b) ROC areas
areaN1 = ROC(histBeforeN1, histAfterN1);
areaN2 = ROC(histBeforeN2, histAfterN2);

%% 4 ROC Detect Probability

% a) Histograms
success = find(~isnan(responseTime));
fails = find(isnan(responseTime));

successTrials_1 = hist(sum(afterStim_1(success,:), 2), 0:8);
failedTrials_1 = hist(sum(afterStim_1(fails,:), 2), 0:8);

successTrials_2 = hist(sum(afterStim_2(success,:), 2), 0:8);
failedTrials_2 = hist(sum(afterStim_2(fails,:), 2), 0:8);

N1_1 = figure(3);
bar(0:8, [failedTrials_1;successTrials_1]');
title('Neuron 1');
xlabel('Spikes/100ms');
ylabel('Number of trials');
legend('Successful Trials', 'Unsuccessful Trials');
saveas(N1_1,'HistN1-1.jpg');

N2_1 = figure(4);
bar(0:8, [failedTrials_2;successTrials_2]');
title('Neuron 2');
xlabel('Spikes/100ms');
ylabel('Number of trials');
legend('Successful Trials', 'Unsuccessful Trials');
saveas(N2_1,'HistN2-1.jpg');

% b) ROC Areas
area_N1 = ROC(failedTrials_1, successTrials_1);
area_N2 = ROC(failedTrials_2, successTrials_2);






