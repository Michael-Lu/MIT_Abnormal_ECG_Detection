clear all
clc
%[DataList, FieldLen] = GatherFeatures(fullfile(pwd,'image_mat_2'));
load DataList

%InputDomain =[106 116 119 200 201 202 203 212 213 228 231];
InputDomain= [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
confusion = [];
err = [];

%--------Parameters to set-----------------
Available_Bands_Coeff = [1:2, 3, 6]
PNN_Spares = 5 %Very importanat parameter. This parameter should at least 2; otherwise, the performance will be poor

EnergyGain =1;
PCAComNum = 40; % 10 is the lowest number that can reach the optimized performance
%------------------------------------------
ratio_testing = 0.05;

Mask = [];
for n=1:size(FieldLen,2)-1
    if ismember(n,Available_Bands_Coeff)
        Mask = [Mask ones(1,FieldLen(n))];
    else
        Mask = [Mask zeros(1,FieldLen(n))];
    end
end
Mask = [Mask [1, 1 0 0, 1 0 0, 1 0 0, 1 0 0 ] ];

Mask = logical(Mask);

DataComponent = [];

Train.Normal = [];
Train.NormalPer = [];
Test.Normal = [];
Test.NormalPer = [];

Train.Abnormal = [];
Train.AbnormalPer = [];
Test.Abnormal = [];
Test.AbnormalPer = [];

for n = 1:length(InputDomain)
    
    perIdx = InputDomain(n);
    %--------Set the Data to Use-----------------
    TargetNormalIdx = (perIdx == cell2mat(DataList.Normal(:,1) ) );
    TargetAbnormalIdx = (perIdx == cell2mat(DataList.Abnormal(:,1) ) );

    NormalPerIdx = find( TargetNormalIdx);
    AbnormalPerIdx = find( TargetAbnormalIdx);
    
    NormalSet = cell2mat( DataList.Normal(TargetNormalIdx , 3) )';
    AbnormalSet = cell2mat( DataList.Abnormal( TargetAbnormalIdx, 3) )';
    
    %------------------------------------------
    normal_testing_num = floor( size(NormalSet,2) * ratio_testing);
    abnormal_testing_num = floor( size(AbnormalSet,2) * ratio_testing);
    
    if abnormal_testing_num == 0
        display([num2str(perIdx) 'No testing abnormal data']);
        continue
    end
    
    if normal_testing_num == 0
        display([num2str(perIdx) 'No testing normal data']);
        continue
    end
    
    assert(~(normal_testing_num <0));
    assert(~(abnormal_testing_num<0));
    
    DataComponent = [DataComponent; {perIdx, ...
                                    size(NormalSet,2)-normal_testing_num, ...
                                    normal_testing_num, ...
                                    size(AbnormalSet,2)-abnormal_testing_num, ...
                                    abnormal_testing_num} ...
                    ];

    
    if ~isempty(NormalPerIdx)
        if normal_testing_num ~= 0
            Test.Normal = [Test.Normal NormalSet(Mask, end-normal_testing_num+1:end)];
            Test.NormalPer = [Test.NormalPer; NormalPerIdx(end-normal_testing_num+1:end) ];
        end
        Train.Normal = [Train.Normal NormalSet(Mask, 1:end-normal_testing_num)];
        Train.NormalPer = [Train.NormalPer; NormalPerIdx(1:end-normal_testing_num) ];
    end
    
    if ~isempty(AbnormalPerIdx)
        if abnormal_testing_num ~= 0
            Test.Abnormal = [Test.Abnormal AbnormalSet(Mask, end-abnormal_testing_num+1:end)];
            Test.AbnormalPer = [Test.AbnormalPer; AbnormalPerIdx(end-abnormal_testing_num+1:end) ];
        end
        Train.Abnormal = [Train.Abnormal AbnormalSet(Mask, 1:end-abnormal_testing_num)];
        Train.AbnormalPer = [Train.AbnormalPer; AbnormalPerIdx(1:end-abnormal_testing_num) ];
    end
   
end

% Train.Normal(end-FieldLen(15)+1:end, :) = Train.Normal(end-FieldLen(15)+1:end, :).*EnergyGain;
% Train.Abnormal(end-FieldLen(15)+1:end, :) = Train.Abnormal(end-FieldLen(15)+1:end, :).*EnergyGain;
% Test.Normal(end-FieldLen(15)+1:end, :) = Test.Normal(end-FieldLen(15)+1:end, :).*EnergyGain;
% Test.Abnormal(end-FieldLen(15)+1:end, :) = Test.Abnormal(end-FieldLen(15)+1:end, :).*EnergyGain;
% 
% ParGain = 1000;
% Train.Normal(11:end,:) = Train.Normal(11:end,:)*ParGain;
% Train.Abnormal(11:end,:) = Train.Abnormal(11:end,:)*ParGain;
% Test.Normal(11:end,:) = Test.Normal(11:end,:)*ParGain;
% Test.Abnormal(11:end,:) = Test.Abnormal(11:end,:)*ParGain;
%% PNN
TrainingSet = [Train.Normal Train.Abnormal];

% apply PCA to TrainingSet
mean_Training = mean(TrainingSet,2);
std_Training = std(TrainingSet,0,2);

[EigVec, Score, Latent] = princomp( zscore(TrainingSet') );

TrainingTarget = [zeros(1, size(Train.Normal,2) ) ones(1, size(Train.Abnormal, 2) ) ] +1;

err = [];
sensitivity = [];
specificity = [];
for pcaIteration = 1:size(Latent,1)
    PCAComNum = pcaIteration;
    Trained_PNN = Train_PNN(Score(:,1:PCAComNum)', TrainingTarget, PNN_Spares);

 %% Confusion Matrix
 
Test_NormalScore = EigVec'*Test.Normal;
Test_AbnormalScore = EigVec'*Test.Abnormal;
    
test_normal_rslt = vec2ind( sim(Trained_PNN, Test_NormalScore(1:PCAComNum,:)) );
test_abnormal_rslt = vec2ind( sim(Trained_PNN, Test_AbnormalScore(1:PCAComNum,:)) );

% Make sure test_normal_rslt and test_abnormal_rslt are both 1-dimension vectors
assert(size(test_normal_rslt,1) == 1);
assert(size(test_abnormal_rslt,1) == 1);

 err(pcaIteration) =  (sum(test_normal_rslt == 2) + sum(test_abnormal_rslt == 1) )/(size(test_normal_rslt,2)+size(test_abnormal_rslt,2) ) *100;
 sensitivity(pcaIteration) = (1-sum(test_abnormal_rslt == 1)/size(test_abnormal_rslt,2) ) *100;
 specificity(pcaIteration)= (1-sum(test_normal_rslt == 2)/size(test_normal_rslt,2) )*100;
end

display('---Person NormalTrain NormalTest AbnormalTrain AbnormalTest---')
DataComponent

display('---normal to abnormal-----');
DataList.Normal(Test.NormalPer(test_normal_rslt == 2), :)

display('---abnormal to normal-----');
DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 1), :)

display('>>>error rate<<<')
% err =  (sum(test_normal_rslt == 2) + sum(test_abnormal_rslt == 1) )/(size(test_normal_rslt,2)+size(test_abnormal_rslt,2) ) *100
% sensitivity = (1-sum(test_abnormal_rslt == 1)/size(test_abnormal_rslt,2) ) *100
sensitivity