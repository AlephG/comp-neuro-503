% demo_1d_RF_sysIdent_overfit.m 
%
% demonstrate overfitting, for simple regression estimation of 1-d (spatial) receptive field
% use hold-back dataset, compare learning curves for training vs validation sets
%   use to illustrate how "early stopping" can work

% note: error = mean-squares not sum-squares

% for early stopping:  save RF estimate when prediction of validation set starts to get worse
function [e] = assign_1d_RF_sysIdent_overfit(stop_early) 
fprintf(1,'\n\n\n\n\n\n');

rng('default');   % "standard" random number seed -> reproducible simulations

nRFpts = 32;    % number of points in receptive field (== number of parameters to be estimated)
nMeasTrain = 70;    % number of measurements to use for receptive field estimation
nMeasValid = 30;
% $$ split into 70 measurements for Training, 30 for Validation ???

eta = 0.1;  %  learning rate 
num_iterations = 50; % number of batch-mode iterations 

% define a model receptive field (Gabor function), and plot it
xPtsK = 1:1:nRFpts;
mu = nRFpts/2;   lambda = nRFpts/5;   sig = lambda*0.5;
env = exp(-(xPtsK-mu).^2/(2*sig^2));  % Gaussian envelope
receptiveField = env.*sin(2*pi*xPtsK/lambda);
figure(1);    
plot(xPtsK,receptiveField,'b-');      grid;

% create input signal (stimulus set):   white noise, range from -1 to +1
stimTrain = (rand(nRFpts,nMeasTrain) - 0.5);   % nMeasTrain measurements, for nRFpts pixels
stimValid = (rand(nRFpts,nMeasValid) - 0.5); 

% simulate response of the model system (receptive field) to input signal:
respTrain = receptiveField*stimTrain + 0.3*randn(1,nMeasTrain);  % (with some added noise) 
respValid = receptiveField*stimValid + 0.3*randn(1,nMeasValid); 
% stim   = nRFpts x nMeas
% resp   = 1 x nMeas           % note stim and resp are ~ zero-mean (as they need to be)
% w      = 1 x nRFpts

% $$ - replicate above, to produce stimValid and respValid 




w = zeros(1,nRFpts);  % initialize weights (receptive field estimate) - "sparse prior"

errTrain = zeros(num_iterations,1);     % initialize histories
errValid = zeros(num_iterations,1); 
early_stop = 15;

for iteration=1:num_iterations    % loop over iterations
    
   respCalc = w*stimTrain;     % predicted response for estimation dataset
   respCalc2 = w*stimValid;
   % gradient descent
   dw = (respCalc - respTrain)*stimTrain'; %  gradient
   w = w - eta*dw;   % learning rule:  update weights 
   errTrain(iteration) = mean((respTrain - respCalc).^2);   % record error-squared for history
   
   % $$  test how well we can now predict the validation dataset -> errValid
   errValid(iteration) = mean((respValid - respCalc2).^2);
   % redraw plot of receptive field estimate 
   plot(xPtsK,receptiveField,'b-',xPtsK,w,'ro');   grid;
   xMin = min(xPtsK);    xMax = max(xPtsK);   % set axis limits, to keep things stable
   yMin = 1.5*min(receptiveField);  yMax = 1.5*max(receptiveField);
   axis ([xMin xMax  yMin yMax]);
   legend('actual receptive field','estimated receptive field');
   drawnow  
    if iteration == 15 && stop_early == 1
        break;
   end
end

if stop_early == 0
    figure(2); 
    hold all;
    plot(1:1:num_iterations,errTrain,'b-');
    plot(1:1:num_iterations,errValid,'m-');
    han.legend = legend('errTrain', 'errValid', 'Location','NorthEast');  % legend in upper right
    set(han.legend,'FontSize',10);
    set(han.legend,'FontWeight','bold');
    set(han.legend,'EdgeColor','black');
    grid on;  xlabel('iterations');  ylabel('MSE');
    drawnow;
    % $$ modifiy above to also plot "errValid"

    %optimal place to stop, iteration 15 (by inspection)

    figure(2);
    text(early_stop, errValid(early_stop,1), '\leftarrow stop');
    text(early_stop, errTrain(early_stop,1), '\leftarrow stop');
end

% Print out relevant info
fprintf(1,'\neta = %5.1f \n', eta); 
fprintf(1,'\nnum_iterations = %.0f \n', num_iterations); 
fprintf(1,'\nLoss for training dataset = %.4f\n', errTrain(iteration, 1));   
fprintf(1,'\nLoss for validation dataset = %.4f\n', errValid(iteration, 1));  


