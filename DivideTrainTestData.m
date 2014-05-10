function [ Train, Test, DataComponent] = DivideTrainTestData( DataList, ratio_testing, testing_PR )
% Divide the Data into TrainingSet and TestingSet according to the TestRatio.
%The ouput will be a cell array containing different combinations of (Training, Testing)
%Note that the Input, DataList should be a structure containing
%DataList.Normal and DataList.Abnormal

if( testing_PR > ceil(1/ratio_testing) )
    throw( MException('DivideTrainTestData:testing_PR', 'The testin_PR exceeds the limit') );
end


DataComponent = [];

Train.Normal = [];
Train.NormalPer = [];
Test.Normal = [];
Test.NormalPer = [];

Train.Abnormal = [];
Train.AbnormalPer = [];
Test.Abnormal = [];
Test.AbnormalPer = []; %The index in DataList

InputDomain = unique( [cell2mat(DataList.Normal(:,1)); cell2mat(DataList.Abnormal(:,1)) ] );


for n = 1:length(InputDomain)
    
    perIdx = InputDomain(n);
    %--------Set the Data to Use-----------------
    TargetNormalMask = (perIdx == cell2mat(DataList.Normal(:,1) ) );
    TargetAbnormalMask = (perIdx == cell2mat(DataList.Abnormal(:,1) ) );

    NormalPerIdx = find( TargetNormalMask);
    AbnormalPerIdx = find( TargetAbnormalMask);
    
    NormalSet = DataList.Normal(TargetNormalMask , :);
    AbnormalSet = DataList.Abnormal( TargetAbnormalMask, :);
    
    %------------------------------------------
    normal_testing_num = ceil( size(NormalSet,1) * ratio_testing);
    abnormal_testing_num = ceil( size(AbnormalSet,1) * ratio_testing);
    
%     if abnormal_testing_num == 0
%         display([num2str(perIdx) 'No testing abnormal data']);
%         ignore_list = [ignore_list perIdx];
%         continue
%     end
%     
%     if normal_testing_num == 0
%         display([num2str(perIdx) 'No testing normal data']);
%         ignore_list = [ignore_list perIdx];
%         continue
%     end
    
%     assert( normal_testing_num > 0);
%     assert( abnormal_testing_num > 0);
% 
%     assert(~isempty(NormalPerIdx));
%     assert(~isempty(AbnormalPerIdx));
    
    if ~isempty(NormalPerIdx)
        if normal_testing_num ~= 0
            bgn = normal_testing_num*(testing_PR-1) + 1;
            endp = min(bgn + normal_testing_num-1, size(NormalSet,1) );
            
            Test.Normal = [Test.Normal; NormalSet(bgn:endp, :)];
            Test.NormalPer = [Test.NormalPer; NormalPerIdx(bgn:endp) ];
        end
        train_mask = ones(1,size(NormalSet,1));
        train_mask(bgn:endp) = 0;
        train_mask = logical(train_mask);
        
        Train.Normal = [Train.Normal; NormalSet(train_mask,:)];
        Train.NormalPer = [Train.NormalPer; NormalPerIdx(train_mask) ];
    end
    
    if ~isempty(AbnormalPerIdx)
        if abnormal_testing_num ~= 0
            
            bgn = abnormal_testing_num*(testing_PR-1) + 1;
            endp = min(bgn + abnormal_testing_num-1, size(AbnormalSet,1) );
            Test.Abnormal = [Test.Abnormal; AbnormalSet(bgn:endp, :)];
            Test.AbnormalPer = [Test.AbnormalPer; AbnormalPerIdx(bgn:endp) ];
        end
        train_mask = ones(1,size(AbnormalSet,1));
        train_mask(bgn:endp) = 0;
        train_mask = logical(train_mask);
        
        Train.Abnormal = [Train.Abnormal; AbnormalSet(train_mask,:)];
        Train.AbnormalPer = [Train.AbnormalPer; AbnormalPerIdx(train_mask) ];
    end
    
    DataComponent = [DataComponent; {perIdx, ...
                                size(NormalSet,1)-normal_testing_num, ...
                                normal_testing_num, ...
                                size(AbnormalSet,1)-abnormal_testing_num, ...
                                abnormal_testing_num} ...
                ];
   
end



end

