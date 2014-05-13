function [ TrainNew, TestNew ] = NormalizeTanSig( TrainFea, TestFea)
% This function first apply 'zscore' normalization and do PCA
% This function first apply 'zscore' to the set [TrainFea],
% then apply PCA to it afterwards, and get the trainning set's eigenvectors and
% production scores in the eigenspace as the output, TrainNew.
% The set, [TestFea] is normalized according to the mean
% and standard deviation of Training Set, and applied inner-product with
% the eigenvectors of Trainning Set to get the production scores, as
% the output, TestNew.


    if ~isa(TrainFea,'double') | ~isa(TestFea,'double')
        throw( MException('Normal izeAndPCA:WrongType','The input features should be numeric double arrays') );
    end
    
    mean_Train = mean(TrainFea, 1);
    std_Train = std(TrainFea, 0 , 1);
    TrainNew = tansig(zscore(TrainNew));
    
    TestNew = tansig((TestFea - repmat(mean_Train, size(TestFea,1), 1) )./repmat(std_Train, size(TestFea,1), 1));

end

