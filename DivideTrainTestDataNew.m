function [ Train, Test ] = DivideTrainTestDataNew( DataList, num_parts, testing_PR )
% Divide the Data into TrainingSet and TestingSet according to the TestRatio.
% The input, DataList can be a cell array or a numerical array, and the output Train and Test
% are both non-overlapping parts retrieve from the input DataList. Each row of
% DataList corresponds to a record.
% If the number of records in DataList is N, then the number of testing
% records will be M = floor(N*ratio_testing). The position of testing data
% will be from M*(testin_PR-1)+1 to (M*testing_PR). testing_PR should be in
% the range of 1 to ceil(N/M). If the testing_PR is set to be ceil(N/M),
% then the testing data contains the records of which position is between
% M*(ceil(M/N)-1) and N.
    if (num_parts - floor(num_parts)) > 0
        throw( MException('DivideTrainTestDataNew:WrongType','The input, num_parts should be an integer') );
    end
    
    numTotalRec = size(DataList,1);
    if numTotalRec == 0
        throw( MException('DivideTrainTestDataNew:InputZeroSize','The input is of zero size!') );
    end
    
    numTestRec = ceil(numTotalRec/num_parts);
    assert(numTestRec > 0);
    
    if testing_PR < 1 || testing_PR > ceil(numTotalRec/numTestRec)
        throw( MException('DivideTrainTestDataNew:OutofRange','testing_PR is out of range!') );
    end
    
    if testing_PR ~= ceil(numTotalRec/numTestRec)
        idx_ = (numTestRec*(testing_PR-1)+1) : (numTestRec*testing_PR);
        Test = DataList(idx_, :);
        
        idx_ = [1 : (numTestRec*(testing_PR-1)), (numTestRec*testing_PR) : numTotalRec];
        Train = DataList(idx_, :);
    else
        idx_ = (numTestRec*(testing_PR-1)+1) : numTotalRec;
        Test = DataList(idx_, :);
        
        idx_ = 1: (numTestRec*(testing_PR-1));
        Train = DataList(idx_, :);
    end
    
end

