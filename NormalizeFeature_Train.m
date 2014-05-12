function [TrainNormal, TrainAbNormal, NormParameters] = NormalizeFeature_Train(NormTrainFea, AbTrainFea)
    % This function Normalized each set of features, and convert them to numeric arrays
    %
    % The output, NormParameters is for the current used normalization method. Pass the
    % returning NormParameters to NormalizeFeature_Test() to Normalize the
    % Feature sets of testing data according to the training data.
    % 
    % The input should be the cell arrays of the trainning Features.
    % 
    % This function should be maintained both with NormalizeFeature_Test()
    if size(NormTrainFea,2) ~= size(AbTrainFea,2)
        throw( MException('NormalizeFeature_Train:LengthMisMatch',...
            'The number of feature sets in NormalTrain isn''t equal to that in AbNormalTrain') );
    end
    
    TrainNormal = cell2mat(NormTrainFea);
    TrainAbNormal = cell2mat(AbTrainFea);
    
    FieldLen = [];
    for n = 1:size(NormTrainFea,2)
        FieldLen = [FieldLen, size(NormTrainFea{1,n}, 2)];
    end
    NormParameters = {FieldLen};
end

