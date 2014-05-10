load PermWorkSpace

PCAComNum = 10;
[ PermDataList, FieldLen ] = GatherFeatures_Perms_Caller( fullfile(pwd,'testbench') );
FinalResult = [];
for perIter = 1:size(PermDataList.Abnormal,1)
    image_num = size(PermDataList.Abnormal{perIter,2},1);
    for imgIter = 1:image_num
        testing_data = cell2mat(PermDataList.Abnormal{perIter,2}{imgIter,2} )';
        testing_data = testing_data(Mask,:);
        testing_data_score = EigVec'*(testing_data-repmat(mean_Training, 1, size(testing_data,2) ) );
        test_abnormal_rslt = vec2ind( sim(Trained_PNN, testing_data_score(1:PCAComNum,:)) );
        
        FinalResult = [FinalResult; {PermDataList.Abnormal{perIter,1}, ...
            PermDataList.Abnormal{perIter,2}{imgIter,1}, ...
            sum(test_abnormal_rslt==2) }];
    end
end