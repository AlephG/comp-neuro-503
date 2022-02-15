%% Assignment 5: Supervised Learning
% Solim Legris
% Student ID: 260807111
% PLEASE RUN ONE SECTION AT A TIME

%% Part I: Single-layer classifier

% Test different values for the learning rate and choose the best one

weights = zeros(3, 350, 6);
lr = [0.01 0.1 0.5 0.75 0.9 1 2];
for i=1:length(lr)
    [loss(i) weights(:,:,i) per_batch_loss(:,i)] = assign_classifier_gradDesc(lr(i), 0, 350);    
end

[min_loss, index] = min(loss);
eta = lr(index);

%Graph loss as a function of iteration number
figure(1);

plot([1:350], per_batch_loss(:,1), ...
    [1:350], per_batch_loss(:,6), ...
    [1:350], per_batch_loss(:,7));
title('Loss versus iteration');
xlabel('Iteration'); ylabel('Loss');
legend(sprintf('eta = %s', num2str(lr(1), 2)), sprintf('eta = %s', num2str(lr(6))), sprintf('eta = %s', num2str(lr(7))));

%Graph weights as a function of iteration for optimal lr
figure(2);
plot(weights(1,:,index));
hold on;
plot(weights(2,:,index));
hold on;
plot(weights(3,:,index)); 

fprintf(1,'\nMinimum loss = %f\n Optimal eta = %f\n', min_loss, eta);

%% Part II: Single-layer classifier with regularization

% Test different values of the hyperparameter alpha
close all; clear all; 
eta = 1; %Determined by previous section
alpha = [0.001 0.005 0.01 0.05 0.1 0.5 1];
for i=1:length(alpha)
    [loss(i) weights(:,:,i) per_batch_loss(:,i)] = assign_classifier_gradDesc(0.8, alpha(i), 350);    
end
% 
% % Plot the different weights against iteration
figure(3);
plot(weights(1,:,1));
hold on;
plot(weights(2,:,1));
hold on;
plot(weights(3,:,1)); 

figure(4);
plot(weights(1,:,4));
hold on;
plot(weights(2,:,4));
hold on;
plot(weights(3,:,4)); 

figure(5);
plot(weights(1,:,6));
hold on;
plot(weights(2,:,6));
hold on;
plot(weights(3,:,6)); 


%% Part III: RF estimation using regression with early stopping - A
clear all; close all;
assign_1d_RF_sysIdent_overfit(0);

%% Part III: RF estimation using regression with early stopping - B
close all;
assign_1d_RF_sysIdent_overfit(1);




