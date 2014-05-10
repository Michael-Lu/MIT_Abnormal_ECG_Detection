function [TrainNormal, TrainAbNormal, NormParameters] = NormalizeFeature_Train(NormTrainFea, AbTrainFea)
    % This function Normalized each set of features, and convert them to numeric arrays
    %
    % The output, NormParameters is for the current used normalization method. Pass the
    % returning NormParameters to NormalizeFeature_Test() to Normalize the
    % Feature sets of testing data according to the training data.
    % 
    %The input should be the cell arrays of the trainning Features.
    % 
    % This function should be maintained both with NormalizeFeature_Test()
    TrainNormal = cell2mat(NormTrainFea);
    TrainAbNormal = cell2mat(AbTrainFea);
    
    
    FieldLen.RR = size(NormTrain{1,5}, 2);
    FieldLen.LL = size(NormTrain{1,6}, 2);
    FieldLen.ColEnergyLL = size(NormTrain{1,7}, 2);
    FieldLen.SubEnergyLL = size(NormTrain{1,7}, 2);
    NormParmeters = {FieldLen};
end

