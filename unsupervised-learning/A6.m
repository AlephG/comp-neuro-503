%% Assignment 6: Unsupervised Learning
% Solim Legris
% Student ID: 260807111

%% Part I: Machine Learning with k-Means Clustering
%% A - Two distributions with k=3

X = [randn(100,2)+1.5*ones(100,2);...
     randn(100,2)-2*ones(100,2);];
opts = statset('Display','final');

[idx,ctrs] = kmeans(X,3,...
                    'Distance','sqeuclidean',...
                    'Replicates',5,...
                    'Options',opts);
figure(1);
clf;
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)
plot(ctrs(:,1),ctrs(:,2),'kx',...
     'MarkerSize',12,'LineWidth',2)
plot(ctrs(:,1),ctrs(:,2),'ko',...
     'MarkerSize',12,'LineWidth',2)
legend('Cluster 1','Cluster 2','Cluster 3','Centroids',...
       'Location','NW')
figure(2);
clf;
plot(X(:,1),X(:,2),'k.','MarkerSize',12)
%% B - Three distributions with k=2

X = [randn(100,2)+1.5*ones(100,2);...
     randn(100,2)-2*ones(100,2);...
     randn(100,2)+[-3*ones(100,1) 2*ones(100,1)];];
opts = statset('Display','final');

[idx,ctrs] = kmeans(X,2,...
                    'Distance','sqeuclidean',...
                    'Replicates',5,...
                    'Options',opts);
figure(1);
clf;
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(ctrs(:,1),ctrs(:,2),'kx',...
     'MarkerSize',12,'LineWidth',2)
plot(ctrs(:,1),ctrs(:,2),'ko',...
     'MarkerSize',12,'LineWidth',2)
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
figure(2);
clf;
plot(X(:,1),X(:,2),'k.','MarkerSize',12)

%% C - Three distributions with various k
clear;

X = [randn(100,2)+1.5*ones(100,2);...
     randn(100,2)-2*ones(100,2);...
     randn(100,2)+[-3*ones(100,1) 2*ones(100,1)];];
opts = statset('Display','final');

eva = evalclusters(X, 'kmeans', 'silhouette', 'KList',[2:5]); % Use eva with the silhouette measure to determine the optimal k

fprintf(1, 'The optimal k = %d\n', eva.OptimalK);

% Maybe add the code that generates graph as done before...

%% Part II: Learning in the Brain - STDP

% Run the appropriate files as indicated in the assignment guidelines
% Change line 5 of the simSTDPlatencies file to vary g (conductance)


%% Part III: Hopfield Network

%% A: 1) Noise of 10
clear all; 
hopfield_net(100,'mem_ABC.txt',10,1);

%% A: 2) Noise of 15

clear all; 
hopfield_net(100,'mem_ABC.txt',15,1);

%% A: 3) Noise of 25

clear all; 
hopfield_net(100,'mem_ABC.txt',25,1);


%% A: 4) Noise of 50

clear all; 
hopfield_net(100,'mem_ABC.txt',50,1);

%% B: Modified C to D in text file

clear all; 
hopfield_net(100,'mem_ABCcopie.txt',0,1);

%% C: Lyapunov function to show energy convergence

% Change Hopfield network file so that it returns weights and memories 
[w,s,results2] = hopfield_net(100,'mem_ABC.txt',20,1);
%Output the Lupyanov function
lyapunov = (s'*w);
figure(3);
plot(lyapunov);
title('Lyapunov function');
xlabel('States');
ylabel('Energy');

