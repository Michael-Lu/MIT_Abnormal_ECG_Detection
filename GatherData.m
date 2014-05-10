function [DataList] = GatherData(mat_dir)
% Construct a Table of Records from Database
% { [PerID], [ImgID], [normal/abnormal], [seg_beats], [RR], [Coeff LL],
% [ColEnergy.LL], [SubbandEnergy.LL] }

    DataList = [];
    file_list = cellstr( ls(mat_dir) ); %cellstr will deblank the string array and convert into cells
    
    for matIdx = 1:length(file_list)
        fullPathName = fullfile(mat_dir, file_list{matIdx});
        [~, name, ext] = fileparts( fullPathName );
        
        if ~strcmp(ext, '.mat')
            continue
        end
        
        file_cont = load(fullPathName);
        
        %Get the PerIdx and ImgIdx
        Pattern_ = regexp(name,'\d+', 'match');
        [PerIdx, ImgIdx] = Pattern_{:};
        PerIdx = str2double(PerIdx);
        ImgIdx = str2double(ImgIdx);
        
        CoeffVec_ =  getCoeffVec(file_cont.Coeff);
        ColEnergy_ = CalcColEnergy(file_cont.Coeff);
        
        Record_ = [{PerIdx}, {ImgIdx}, {file_cont.grp_abnormal},...
                    {file_cont.seg_beat}, {file_cont.grp_RR},...
                    CoeffVec_(1),...
                    ColEnergy_(1),...
                    {(sum(ColEnergy_{1},2)/numel(CoeffVec_{1}))}... %Subband Energy of LL
                    ];
                
        DataList = [DataList; Record_];
    end
    
        
  

end
    
function CoeffVec = getCoeffVec(Coeff)
    CoeffVec = [];
    CoeffVec = [CoeffVec, {reshape(Coeff{1}.LL', 1, []) }];
    
    for m = 2:length(Coeff)
        CoeffVec = [CoeffVec, {reshape(Coeff{m}.LH', 1, []) }];
        CoeffVec = [CoeffVec, {reshape(Coeff{m}.HL', 1, []) }];
        CoeffVec = [CoeffVec, {reshape(Coeff{m}.HH', 1, []) }];
    end
end

%{
function target_list = Sel_Target_Files(mat_dir, TargetPeople)
    
    target_list = [];
    file_list = cellstr( ls(mat_dir) ); %cellstr will deblank the string array and convert into cells
    
    for matIdx = 1:length(file_list)
        fullPathName = fullfile(mat_dir, file_list{matIdx});
        [~, name, ext] = fileparts( fullPathName );
        
        if ~strcmp(ext, '.mat')
            continue
        else
            MatchPattern = regexp(name,'\d+', 'match');
            if ismember(MatchPattern(1) , TargetPeople )
                target_list = [target_list; {fullPathName} ];
            end
        end
    end
    
end
%}

function [ColEnergy] = CalcColEnergy(Coeff)
    if ~isa(Coeff,'cell')
        throw( MException('CalcSubEnergy:TypeError','Coeff Should be a cell') );
    end
    
    ColEnergy = [];
    
    %Calculate the first resolution level
    tmpSum = sum(Coeff{1}.LL.^2,1);
    ColEnergy = [ColEnergy, {tmpSum }];
    clear tmpSum
    
    %Calculate the rest resolution levels
    for n = 2:length(Coeff)
        tmpSum = sum(Coeff{n}.LH.^2,1);
        ColEnergy = [ColEnergy, {tmpSum }];
        
        tmpSum = sum(Coeff{n}.HL.^2,1);
        ColEnergy = [ColEnergy, {tmpSum }];

        
        tmpSum = sum(Coeff{n}.HH.^2,1);
        ColEnergy = [ColEnergy, {tmpSum }];
        clear tmpSum
    end
    
end
