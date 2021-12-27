% Create the network
% layers = [
%     featureInputLayer(size(net_in_train, 1), 'Name','input')
%     fullyConnectedLayer(2*size(net_in_train, 1), 'Name','fc1')
%     reluLayer('Name', 'act1')
%     dropoutLayer(0.1)
%     fullyConnectedLayer(100, 'Name','fc2')
%     reluLayer('Name', 'act2')
%     dropoutLayer(0.1)
%     fullyConnectedLayer(100, 'Name','fc3')
%     reluLayer('Name', 'act3')
%     dropoutLayer(0.1)
%     fullyConnectedLayer(100, 'Name','fc4')
%     reluLayer('Name', 'act4')
%     dropoutLayer(0.1)
%     fullyConnectedLayer(size(net_out_train, 1), 'Name','fc5')
%     sigmoidLayer('Name', 'act5')
%     regressionLayer("Name", 'regr_net_out')
% ];

% Set parameters
maxEpochs = 50;
epochIntervals = 1;
initLearningRate = 0.001;
learningRateFactor = 0.8;
l2reg = 1;
miniBatchSize = 1024;
options = trainingOptions('adam', ...
    'InitialLearnRate',initLearningRate, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',5, ...
    'LearnRateDropFactor',learningRateFactor, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'GradientThresholdMethod','l2norm', ...
    'ValidationData', {net_in_lstm_valid, net_out_valid'},...
    'OutputNetwork', 'best-validation-loss',...
    'Plots', 'training-progress',...
    'Verbose',false,...
    'ExecutionEnvironment', 'gpu');

% Train the network
net = trainNetwork(net_in_lstm_train, net_out_train', lgraph_2, options);