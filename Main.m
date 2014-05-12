% This file is the main program to call each functions and do the detection
% test.
clear all
clc
mat_dir = fullfile(pwd,'image_mat_2');
num_parts = 2;
PNN_Spares = 5;
InputDomain = [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
DataComp = []; %List the number of Normal Records and Abnormal Records in each Person
%DataList = GatherData(mat_dir);
%save DataListNew
load DataListNew

err = zeros(size(InputDomain,2), num_parts);
sensitivity = zeros(size(InputDomain,2), num_parts);
specificity = zeros(size(InputDomain,2), num_parts);
for m = 1:size(InputDomain,2)
    %% Separate out the Normal and Abnormal Data Sets in a Person.
    targetPer = InputDomain(m);
    targetDataList = DataList( cell2mat(DataList(:,1)) == targetPer, : );
    
    NormalMask_ = cell2mat(targetDataList(:,3)) == 0 ;
    NormalDataList = targetDataList( NormalMask_, : );
    AbNormalDataList = targetDataList( ~NormalMask_, :);
    clear NormalMask_
    
    DataComp = [DataComp;
                [targetPer, size(NormalDataList,1), ceil(size(NormalDataList,1)/num_parts),...
                           size(AbNormalDataList,1), ceil(size(AbNormalDataList,1)/num_parts)] 
                ];
    if size(NormalDataList,1) == 0 || size(AbNormalDataList,1) == 0
        continue
    end
    
    %% Perparation to Cross-Validation, Separate out the Testing and Training
    for n = 1:num_parts
        [NormTrain, NormTest] = DivideTrainTestDataNew(NormalDataList, num_parts, n);
        [AbTrain, AbTest] = DivideTrainTestDataNew(AbNormalDataList, num_parts, n);
        
    
    
    %% Normalize the Features and Store Them in Numeric Array
    [Train.Normal, Train.AbNormal, NormParameters] = NormalizeFeature_Train( NormTrain(:,5:8), AbTrain(:,5:8) );
    [Test.Normal, Test.AbNormal] = NormalizeFeature_Test(NormParameters, NormTest(:,5:8), AbTest(:,5:8) );
  
   %% Classify the Normalized Feature by PNN
    TrainingSet = [Train.Normal; Train.AbNormal]';
    TrainingTarget = [zeros(1, size(Train.Normal,1) ) ones(1, size(Train.AbNormal, 1) ) ] + 1;
    Trained_PNN = Train_PNN(TrainingSet, TrainingTarget, PNN_Spares);
    
    TestRslt.Normal = vec2ind( sim(Trained_PNN, Test.Normal') );
    TestRslt.AbNormal = vec2ind( sim(Trained_PNN, Test.AbNormal') );
    
    % Make sure test_normal_rslt and test_abnormal_rslt are both 1-dimension vectors
    assert(size(TestRslt.Normal,1) == 1);
    assert(size(TestRslt.AbNormal,1) == 1);
    %% Analyze the Error Rate of Each Result

    display('---normal to abnormal-----');
    NormTest(TestRslt.Normal == 2, :)

    display('---abnormal to normal-----');
    AbTest(TestRslt.AbNormal == 1, :)

    display('>>>error rate<<<')
    err(m,n) =  (sum(TestRslt.Normal == 2) + sum(TestRslt.AbNormal == 1) )/(size(TestRslt.Normal,2)+size(TestRslt.AbNormal,2) ) *100;
    sensitivity(m,n) = (1-sum(TestRslt.AbNormal == 1)/size(TestRslt.AbNormal,2) ) *100;
    specificity(m,n) = (1-sum(TestRslt.Normal == 2)/size(TestRslt.Normal,2) ) *100;
    
    end
    
    
end

display('---Person NormalTrain NormalTest AbnormalTrain AbnormalTest---')
DataComponent()

