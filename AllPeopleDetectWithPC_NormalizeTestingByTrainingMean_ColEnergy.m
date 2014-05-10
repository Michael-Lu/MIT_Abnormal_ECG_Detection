clear all
clc
%[DataList, FieldLen] = GatherFeatures(fullfile(pwd,'image_mat_2'));
load DataList
%  load MissDataList
%  DataList.Normal = RRFalse;
%  DataList.Abnormal = RRMiss;

%InputDomain =[106 116 119 200 201 202 203 212 213 228 231];
InputDomain= [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
confusion = [];
err = [];

%--------Parameters to set-----------------
Available_Bands_Coeff = [1]
PNN_Spares = 5 %Very importanat parameter. This parameter should at least 2; otherwise, the performance will be poor


%------------------------------------------
ratio_testing = 0.5;

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
    
    if abnormal_testing_num == 0
        display([num2str(perIdx) 'No testing abnormal data']);
        continue
    end
    
    if normal_testing_num == 0
        display([num2str(perIdx) 'No testing normal data']);
        continue
    end
    
    assert( normal_testing_num > 0);
    assert( abnormal_testing_num > 0);
    
    DataComponent = [DataComponent; {perIdx, ...
                                    size(NormalSet,2)-normal_testing_num, ...
                                    normal_testing_num, ...
                                    size(AbnormalSet,2)-abnormal_testing_num, ...
                                    abnormal_testing_num} ...
                    ];

    assert(~isempty(NormalPerIdx));
    assert(~isempty(AbnormalPerIdx));
    
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

% TrainingSet(1:10,:) = (TrainingSet(1:10,:)-repmat(mean(TrainingSet(1:10,:),1),10,1))./repmat(std(TrainingSet(1:10,:),0,1),10,1);
%TrainingSet(11:23,:) = (TrainingSet(11:23,:)-repmat(mean(TrainingSet(11:23,:),1),13,1))./repmat(std(TrainingSet(11:23,:),0,1),13,1);
%TrainingSet(1:13,:) = (TrainingSet(1:13,:)-repmat(mean(TrainingSet(1:13,:),1),13,1))./repmat(std(TrainingSet(1:13,:),0,1),13,1);
%Test.Normal(1:13,:) = (Test.Normal(1:13,:)-repmat(mean(Test.Normal(1:13,:),1),13,1))./repmat(std(Test.Normal(1:13,:),0,1),13,1);
%Test.Abnormal(1:13,:) = (Test.Abnormal(1:13,:)-repmat(mean(Test.Abnormal(1:13,:),1),13,1))./repmat(std(Test.Abnormal(1:13,:),0,1),13,1);

Test.Normal(1:10,:) = (Test.Normal(1:10,:)-repmat(mean(Test.Normal(1:10,:),1),10,1))./repmat(std(Test.Normal(1:10,:),0,1),10,1);
Test.Abnormal(1:10,:) = (Test.Abnormal(1:10,:)-repmat(mean(Test.Abnormal(1:10,:),1),10,1))./repmat(std(Test.Abnormal(1:10,:),0,1),10,1);
% apply PCA to TrainingSet
mean_Training = mean(TrainingSet,2);
std_Training = std(TrainingSet,0,2);

[EigVec, Score, Latent] = princomp( TrainingSet');

TrainingTarget = [zeros(1, size(Train.Normal,2) ) ones(1, size(Train.Abnormal, 2) ) ] +1;

err = [];
sensitivity = [];
specificity = [];
for pcaIteration = 1:size(Latent,1)
    PCAComNum = pcaIteration;
    Trained_PNN = Train_PNN(Score(:,1:PCAComNum)', TrainingTarget, PNN_Spares);

 %% Confusion Matrix
 
Test_NormalScore = EigVec'*(Test.Normal-repmat(mean_Training, 1, size(Test.Normal,2) ) );
Test_AbnormalScore = EigVec'*(Test.Abnormal-repmat(mean_Training, 1, size(Test.Abnormal,2) ) );
    
test_normal_rslt = vec2ind( sim(Trained_PNN, Test_NormalScore(1:PCAComNum,:)) );
test_abnormal_rslt = vec2ind( sim(Trained_PNN, Test_AbnormalScore(1:PCAComNum,:)) );

% Make sure test_normal_rslt and test_abnormal_rslt are both 1-dimension vectors
assert(size(test_normal_rslt,1) == 1);
assert(size(test_abnormal_rslt,1) == 1);


 err(pcaIteration) =  (sum(test_normal_rslt == 2) + sum(test_abnormal_rslt == 1) )/(size(test_normal_rslt,2)+size(test_abnormal_rslt,2) ) *100;
 sensitivity(pcaIteration) = (1-sum(test_abnormal_rslt == 1)/size(test_abnormal_rslt,2) ) *100;
 specificity(pcaIteration)= (1-sum(test_normal_rslt == 2)/size(test_normal_rslt,2) )*100;
end

%return
%% Analyze the sensitivity with respect to each person

    ErrorCase_MissDetect = cell2mat( DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 1), 1) );
    ErrorCase_FalseAlarm = cell2mat( DataList.Normal(Test.NormalPer(test_normal_rslt == 2), 1) );

TestingPersonList = cell2mat(DataComponent(:,[1, 3, 5]) );
PerSens = [];
PerSpec = [];
for iter = 1:size(TestingPersonList,1)
   PerSens(iter) = 1- sum(ErrorCase_MissDetect==TestingPersonList(iter,1))/TestingPersonList(iter,3);
   PerSpec(iter) = 1- sum(ErrorCase_FalseAlarm==TestingPersonList(iter,1))/TestingPersonList(iter,2);
end

display('---Person---Sensitivity---Specificity');
[TestingPersonList(:,1) PerSens' PerSpec']
    
display('---Person NormalTrain NormalTest AbnormalTrain AbnormalTest---')
DataComponent


display('---normal to abnormal-----');
DataList.Normal(Test.NormalPer(test_normal_rslt == 2), :)

display('---abnormal to normal-----');
DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 1), :)
display('----miss detection info');

SampleInfo = ListSampleInfo(DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 1), :), fullfile(pwd,'image_mat_2') );
SampleInfo_Right = ListSampleInfo(DataList.Abnormal(Test.AbnormalPer(test_abnormal_rslt == 2), :), fullfile(pwd,'image_mat_2') );

miss_detected_beat =[];
right_detected_beat =[];
num_miss_detected_beat = zeros(38,1);
num_right_detected_beat = zeros(38,1);

for item = 1:size(SampleInfo,1)
    display([num2str(SampleInfo{item,1}), '    ', num2str(SampleInfo{item,2}), '    ', num2str(SampleInfo{item,3}) ]);
    miss_detected_beat = union(miss_detected_beat, SampleInfo{item,3});
    num_miss_detected_beat(miss_detected_beat) = num_miss_detected_beat(miss_detected_beat)+1;
end

for item = 1:size(SampleInfo_Right,1)
    right_detected_beat = union(right_detected_beat, SampleInfo_Right{item,3});
    num_right_detected_beat(right_detected_beat) = num_right_detected_beat(right_detected_beat)+1;
end


display('>>>error rate<<<')
% err =  (sum(test_normal_rslt == 2) + sum(test_abnormal_rslt == 1) )/(size(test_normal_rslt,2)+size(test_abnormal_rslt,2) ) *100
% sensitivity = (1-sum(test_abnormal_rslt == 1)/size(test_abnormal_rslt,2) ) *100
sensitivity
specificity