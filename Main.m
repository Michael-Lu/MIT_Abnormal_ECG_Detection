% This file is the main program to call each functions and do the detection
% test.
clear all
clc
mat_dir = fullfile(pwd,'image_mat_2');
num_parts = 2;
InputDomain = [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
DataComp = []; %List the number of Normal Records and Abnormal Records in each Person
%DataList = GatherData(mat_dir);
%save DataListNew
load DataListNew

for m = 1:size(InputDomain,2)
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
    
    % Do Cross-Validation Test
    for n = 1:1%ceil(1/num_parts)
        [NormTrain, NormTest] = DivideTrainTestDataNew(NormalDataList, num_parts, n);
        [AbTrain, AbTest] = DivideTrainTestDataNew(AbNormalDataList, num_parts, n);
        
    end
        
    [Train.Normal, Train.AbNormal, NormParameters] = NormalizeFeature_Train( NormTrain(:,5:8), AbTrain(:,5:8) );
    [Test.Normal, Test.AbNormal] = NormalizeFeature_Test(NormParameters, NormTest(:,5:8), AbTest(:,5:8) );
    
    
end

