% assign_2d_RF_sysIdent.m
%
% simulated estimation of 2d spatial receptive field of visual cortex simple cell
% uses 'scg' (scaled conjugate gradient) optimization, so no need to specify step size
% simple regression with netlab, using a glm, to estimate Gabor-RF (simulated neuron/filter response waveform)
% glm-fit uses ridge regression, with regularization parameter "alpha"
% use training dataset to get estimate of RF map 
%   using this estimated model, evaluates VAF on holdback validationdataset, for a given alpha

%   figure 1:  example stimulus images
%   figure 2:  model filter, and estimate of rfMap
 

% needs to run:
%   netlab - folder of functions from netlab toolbox
%   getStimulusMovies.m - construct movies, or read from files
%   makeModelRF.m - create linear gabor filter, for model
%   imagescZadj.m - imagesc, but force mid-range of color-map to be at zero
%   hwr.m - half wave rectification

clear all;  fprintf(1,'\n\n\n\n\n\n');   close all;  

rng('default');  % "standard" random number seed -> reproducible simulations 

% addpath('netlab');

%  choose stimulus   %%%%%%%%%%%%%%%
commandwindow
stimType = input('stimulus:  white noise (1) or natural images (2):  ');
if stimType==1
    option.stimulus = 'white';
else
    option.stimulus = 'McGill_clips';
end
clear stimType;

algoType = input('stimulus:  cross-correlation (1) or scg-regression (2):  ');
if algoType==1
    option.algorithm = 'crossCorr';
else
    option.algorithm = 'scg';
end
clear algoType;

% partion data:  most for training, some for validation 
nMovies.train  = 4;
nMovies.valid = 1;
nMovies.total = nMovies.train + nMovies.valid; 
if (nMovies.total > 6)
    error('sorry, we only have 6 movie response datasets');
end

%Create test data set
nMovies.test = 1;

imgSiz  = 32;     % width/height of stimulus/filter/rfMap  
nPixels = imgSiz^2; 

durSec = 5;   refreshHz = 75;  % simulate 5 seconds at 75 hz frame rate
nFrames = durSec*refreshHz;  % e.g. 5 sec at 75 hz  (="ndata" in netlab)
if nFrames>375
    error('too many frames for these movie files !');
end

% specify model receptive field (Gabor function followed by half-power law)
model.lambda = 8;  
model.ori    = -45;  
model.pwrExp = 2; % input('power law exponent:   ');

%  graph specs
fig.stim.pos          = [400 200 300 300];     %[xOff yOff xSize ySize];
fig.stim.handle       = figure('position',fig.stim.pos,'toolbar','none','menubar','none','name','stimulus');
fig.model.pos         = [50 600 300 400];  
fig.model.handle      = figure('position',fig.model.pos,'toolbar','none','menubar','none','name','model');

%  create model filter, and plot in Figure 1 
rfModel = makeModelRF(model,imgSiz);    % creates model filter (Gabor function)
rfModelVec  = reshape(rfModel,1,nPixels);      % make a 1d version, for later use            

%  partition full dataset into 2 subsets, for training and validation 
stimMovie      = zeros(nPixels,nFrames);
stimMovieTrain   = [];
stimMovieValid   = [];
stimMovieTest    = [];
respTrain        = [];
respValid        = [];
respTest         = [];
for iMovie=1:nMovies.total
    getStimulusMovies;            % -> stimMovie = nPixels x nFrames, range -1 to +1
    output = rfModelVec*stimMovie;    % linear filter response to the stimulus    
    output = hwr(output);  % half-wave rectify (set negative values to zero)
    output = output.^model.pwrExp;  % power-low for positive values
                   
    % accumulate results in dataset partitions: 
    if iMovie<=nMovies.train
        stimMovieTrain = [stimMovieTrain stimMovie]; % nPixels x nFrames*nMovies.train
        respTrain    = [respTrain    output];        %     1   x nFrames*nMovies.train  
    else 
        stimMovieValid  = [stimMovieValid stimMovie];  % nPixels x nFrames*nMovies.valid
        respValid     = [respValid    output];          %     1   x nFrames*nMovies.valid 
    end
end  % end of iMovie-loop

%Use rest of dataset for test set
getStimulusMovies;            % -> stimMovie = nPixels x nFrames, range -1 to +1
output = rfModelVec*stimMovie;    % linear filter response to the stimulus    
output = hwr(output);  % half-wave rectify (set negative values to zero)
output = output.^model.pwrExp;  % power-low for positive values
stimMovieTest = [stimMovieTest stimMovie];
respTest = [respTest output];

if strcmp(option.algorithm,'scg')
    % initialize options for optimization
    nin  = imgSiz^2; % number of inputs
    nout = 1;        % number of outputs:  one neuron
    netOptions     = zeros (1,18); 
    netOptions(1)  = 0;
    netOptions(2)  = .0001;      % termination criterion: distance moved
    netOptions(3)  = netOptions(2); % for scg, use VERY small value, eg 10^-9
    netOptions(14) = 200;    % max no of iterations - should be >= no of dim.s ?
    
    alpha_values    = logspace(-3, 5);
    
    for i=1:length(alpha_values)
        % estimate rfMap, for this alpha
        net = glm(nin, nout,'linear',alpha_values(i));       % initialize structure  
        net.w1 = 0*net.w1;    net.b1 = 0*net.b1;   % sparse prior
        [net, netOptions] = netopt(net,netOptions,stimMovieTrain',respTrain','scg');
        rfMap2d   = reshape(net.w1,imgSiz,imgSiz);  % reshape to 2d 
        rfMapVec    = reshape(rfMap2d,nPixels,1);    % make a 1-d version
        
        rfMapVec_iter(:, i)   = rfMapVec;
        rfMap2d_iter(:, :, i) = rfMap2d;
    end
    
elseif strcmp(option.algorithm,'crossCorr')
    nLags=1; maxLag=0;  % (settings to make xcorr.m give us what we want)
    crossCorrAll = zeros(nPixels,nMovies.train*nFrames);
    for iPix=1:nPixels
        crossCorrAll(iPix,:) = xcorr(respTrain,stimMovieTrain(iPix,:),maxLag,'unbiased');  % cross-correlation
    end
    rfMap = crossCorrAll(:,end-nLags+1:end);  % only take positive lagged values
    rfMap2d = reshape(rfMap,imgSiz,imgSiz);  % reshape into 2d
    rfMapVec  = reshape(rfMap2d,nPixels,1);    % make a 1-d version
    clear iPix crossCorrAll rfMap nLags maxLag;
else
    error('unrecognized algorithm');
end

% show some example stimulus images
figure(fig.stim.handle);
for ix=1:4
    stimImgVec = stimMovie(:,ix+20);
    stimImg = reshape(stimImgVec,imgSiz,imgSiz);
    subplot(2,2,ix);
    imagescZadj(stimImg); axis image; axis off; colormap('gray');
end


if strcmp(option.algorithm,'scg')
    for i=1:length(alpha_values)

    % use rfMap estimate to generate prediction of the training and validation
    % responses
    % predRespTrain(:, i) = rfMapVec_iter(:, i)'*stimMovieTrain; 
    predRespValid(:, i) = rfMapVec_iter(:, i)'*stimMovieValid; 

    %residValidNew(:, i) = respValid - predRespValid(:, i)';  % residual - error in prediction of validation response

    % calculate VAF for validation dataset
    vaf.R_matrix = corrcoef(respValid,predRespValid(:, i)');  % -> 2x2 matrix, ones on diagonal
    vaf.offDiag = vaf.R_matrix(1,2);
    vaf.vaf(i) = vaf.offDiag^2.;   
    end

    [best_VAF index] = max(vaf.vaf);

    fprintf(1,'\nVAF for validation dataset = %5.1f percent\n', 100*best_VAF);

    %calculate VAF for test dataset
    predRespTest = rfMapVec_iter(:, index)'*stimMovieTest; 
    vaf.R_matrix = corrcoef(respTest,predRespTest);  % -> 2x2 matrix, ones on diagonal
    vaf.offDiag = vaf.R_matrix(1,2);
    vaf.vafTest = vaf.offDiag^2.;

    fprintf(1,'\nVAF for test dataset = %5.1f percent\n', 100*vaf.vafTest);
    
    % graph estimated rfMap, below "actual" (model) receptive field:
    f = figure(fig.model.handle); 
    subplot(4,1,1);
    imagescZadj(rfModel);  hold on; axis image; axis off; colorbar; title('RF model filter');
    subplot(4,1,2);  
    imagescZadj(rfMap2d_iter(:,:, index)); title(['Alpha = ', num2str(alpha_values(index), 3)]);
    axis image; axis off; colorbar;
    subplot(4,1,3);  
    imagescZadj(rfMap2d_iter(:,:, index-20)); title(['Alpha = ', num2str(alpha_values(index-20), 3)]);
    axis image; axis off; colorbar;
    subplot(4,1,4);  
    imagescZadj(rfMap2d_iter(:,:, index+15)); title(['Alpha = ', num2str(alpha_values(index+15), 3)]);
    axis image; axis off; colorbar;
    hold off;
    saveas(f, 'rfmap_plots_natural.png');
    figure(3); 
    semilogx(alpha_values, vaf.vaf);
    title('VAF versus alpha for white noise images'); %title('VAF versus alpha for natural images'); %
    xlabel('alpha'); ylabel('VAF');
    text(alpha_values(index), vaf.vaf(index), ['\leftarrow maximum VAF = ', num2str(vaf.vaf(index), 3)]);
    
elseif strcmp(option.algorithm,'crossCorr')
        % graph estimated rfMap, below "actual" (model) receptive field:
    figure(fig.model.handle); 
    subplot(2,1,1);
    imagescZadj(rfModel);  hold on; axis image; axis off; colorbar; title('RF model filter');
    subplot(2,1,2);  
    imagescZadj(rfMap2d); 
    hold on; axis image; axis off; colorbar;
    if strcmp(option.stimulus, 'white')
        im_type = 'white noise images';
    else
        im_type = 'natural image';
    end
    title(sprintf('RF estimate for cross-correlation with %s', im_type));    
  

    % use rfMap estimate to generate prediction of the training and validation responses)
    % predRespTrain = rfMapVec'*stimMovieTrain; 
    predRespValid = rfMapVec'*stimMovieValid; 
    predRespTest = rfMapVec'*stimMovieTest; 

    residValidNew = respValid - predRespValid;  % residual - error in prediction of validation response

    % calculate VAF for validation dataset
    vaf.R_matrix = corrcoef(respValid,predRespValid);  % -> 2x2 matrix, ones on diagonal
    vaf.offDiag = vaf.R_matrix(1,2);
    vaf.vaf = vaf.offDiag^2.;
    fprintf(1,'\nVAF for validation dataset = %5.1f\n', 100*vaf.vaf);   
    
    %calculate VAF for test dataset
    vaf.R_matrix = corrcoef(respTest,predRespTest);  % -> 2x2 matrix, ones on diagonal
    vaf.offDiag2 = vaf.R_matrix(1,2);
    vaf.vafTest = vaf.offDiag2^2.;
    fprintf(1,'\nVAF for test dataset = %5.1f percent\n', 100*vaf.vafTest);   
     
 end
 
