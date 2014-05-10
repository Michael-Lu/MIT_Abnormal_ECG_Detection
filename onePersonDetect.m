clear all
clc
[DataList, FieldLen] = GatherFeatures(fullfile(pwd,'image_mat_2'));


SAVEDFILENAME= [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
confusion = [];
err = [];

%--------Parameters to set-----------------
num_available_fields = 1:2
num_NormalToTest = 20;
num_AbnormalToTest = 20;
PNN_Spares = 8; %Very importanat parameter. This parameter should at least 2; otherwise, the performance will be poor
%------------------------------------------


Mask = [];
for n=1:size(FieldLen,2)
    if ismember(n,num_available_fields)
        Mask = [Mask ones(1,FieldLen(n))];
    else
        Mask = [Mask zeros(1,FieldLen(n))];
    end
end
Mask = logical(Mask);

for n = 1:length(SAVEDFILENAME)
    perIdx = SAVEDFILENAME(n);
    
    %--------Set the Person to Test-----------------
    TargetPerson = perIdx;

    %------------------------------------------
    
    
    
    NormalSet = cell2mat( DataList.Normal( cell2mat( DataList.Normal(:,1) ) == TargetPerson , 3) )';
    AbnormalSet = cell2mat( DataList.Abnormal( cell2mat( DataList.Abnormal(:,1) ) == TargetPerson, 3) )';
    
    DataNumRep(n,:) = [perIdx, size(NormalSet,2), size(AbnormalSet,2)];
    
    if (DataNumRep(n,2) < num_NormalToTest) || (DataNumRep(n,3) < num_AbnormalToTest )  
        continue
    end
    
    TrainingSet = [NormalSet(Mask,1:end-num_NormalToTest) AbnormalSet(Mask,1:end-num_AbnormalToTest)];
    TrainingTarget = [zeros(1, size(NormalSet(Mask,1:end-num_NormalToTest),2) ) ones(1, size(AbnormalSet(Mask,1:end-num_AbnormalToTest), 2) ) ] +1;
    Trained_PNN = Train_PNN(TrainingSet, TrainingTarget, PNN_Spares);
    
    %% Confusion Matrix
    
    test_normal_rslt = vec2ind( sim(Trained_PNN, NormalSet(Mask,end-num_NormalToTest+1:end) ) );
    test_abnormal_rslt = vec2ind( sim(Trained_PNN, AbnormalSet(Mask,end-num_AbnormalToTest+1:end) ) );
    
    cur_Confusion = [sum(test_normal_rslt == 1, 2),  sum(test_normal_rslt ==2, 2); sum(test_abnormal_rslt == 1, 2), sum(test_abnormal_rslt ==2, 2)];
    confusion =[ ...
        confusion; ...
        { perIdx, cur_Confusion }...
        ];
    
    err =[ err; ...
        { perIdx, [cur_Confusion(1,2)/sum(cur_Confusion(1,:),2)    cur_Confusion(2,1)/sum(cur_Confusion(2,:),2) (cur_Confusion(1,2)+cur_Confusion(2,1))/sum(sum(cur_Confusion)) ] } ...
        ];
end
display('Person--NormaltoAbnormal--AbnormaltoNormal---TotalError--(%)');
[cell2mat(err(:,1)) cell2mat(err(:,2)).*100]