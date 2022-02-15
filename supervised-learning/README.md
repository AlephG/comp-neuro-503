# Supervised learning

Parts I, II and III can be run from `A5_code.m`. Part IV can be run from `assign_2d_RF_sysIdent.m`.

## Part I: Single-Layer Classifier
In this section, I train a single-layer classifier and try different learning rates to find the optimal one.

## Part II: Single-Layer Classifier with Regularization
In this seciton, I train a single-layer classifier and add regularization to the training by penalizing weight growth using sum-squared weights. I try different values of alpha, the hyperparameter that controls how drastic the regularization penalty is and find the optimal value.

## Part III: Receptive Field Estimation using Regression
In this section, I estimate a receptive field by using gradient descent linear regression to fit the data. I also use early stopping to find the optimal number of training trials needed before the model overfits the data.

## Part IV: Comparing RF Estimation from Regression and Cross-Correlation
In thsi section, I compare RF estimation as obtained from gradient descent regressions and from cross-correlation.
