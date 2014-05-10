clear all
clc
%[DataList, FieldLen] = GatherFeatures(fullfile(pwd,'image_mat_2'));
load DataList

InputDomain= [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
confusion = [];
err = [];

%--------Parameters to set-----------------
Available_Bands_Coeff = [15]%[1:3]
PNN_Spares = 5 %Very importanat parameter. This parameter should at least 2; otherwise, the performance will be poor
%------------------------------------------
ratio_testing = 0.2;

Mask = [];
for n=1:size(FieldLen,2)
    if ismember(n,Available_Bands_Coeff)
        Mask = [Mask ones(1,FieldLen(n))];
    else
        Mask = [Mask zeros(1,FieldLen(n))];
    end
end


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

TrainingSet = [Train.Normal Train.Abnormal];
TrainingTarget = [zeros(1, size(Train.Normal,2) ) ones(1, size(Train.Abnormal, 2) ) ] +1;

mean_Train = mean(TrainingSet,2);
std_Train = std(TrainingSet,0,2);

Trained_PNN = Train_PNN( zscore(TrainingSet')', TrainingTarget, PNN_Spares);

 %% Confusion Matrix


Scaled_Test_Normal = (Test.Normal - repmat(mean_Train, 1, size(Test.Normal,2)) )./ repmat(std_Train, 1, size(Test.Normal,2));
Scaled_Test_Abnormal = (Test.Abnormal - repmat(mean_Train, 1, size(Test.Abnormal,2)) )./ repmat(std_Train, 1, size(Test.Abnormal,2));


test_normal_rslt = vec2ind( sim(Trained_PNN, Scaled_Test_Normal) );
test_abnormal_rslt = vec2ind( sim(Trained_PNN, Scaled_Test_Abnormal) );

% Make sure test_normal_rslt and test_abnormal_rslt are both 1-dimension vectors
assert(size(test_normal_rslt,1) == 1);
assert(size(test_abnormal_rslt,1) == 1);

display('---Person NormalTrain NormalTest AbnormalTrain AbnormalTest---')
DataComponent

display('---normal to abnormal-----');
DataList.Normal(Test.NormalPer(test_normal_rslt == 2), :)

display('---abnormal to normal-----');
DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 1), :)

display('>>>error rate<<<')
err =  (sum(test_normal_rslt == 2) + sum(test_abnormal_rslt == 1) )/(size(test_normal_rslt,2)+size(test_abnormal_rslt,2) ) *100
sensitivity = (1-sum(test_abnormal_rslt == 1)/size(test_abnormal_rslt,2) ) *100
specificity = (1-sum(test_normal_rslt == 2)/size(test_normal_rslt,2) ) *100