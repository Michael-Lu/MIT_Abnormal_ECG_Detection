function [DataList FieldLen] = GatherFeatures(mat_dir)
% FieldLen is an array indicates the length of each field( RR, LL, LH...)
% DataList.Normal = {[Person_ID], [Picture_No],  [ RR | LL | LH | HL | HH |...], [Energies of each bands]}, each rows of the array on
% the right is features of one picture generated from a certain person.
% DataList.Abnormal = {[Person_ID], [Picture_No], [ RR | LL | LH | HL | HH |...], [Energies of each bands]} 
    DataList = struct('Normal',[], 'Abnormal', []);
    file_list = cellstr( ls(mat_dir) );
    
    %% Determine FieldLen
    for matIdx = 1:length(file_list)
        [~, ~, ext] = fileparts( fullfile(mat_dir, file_list{matIdx}) );
        
        if ~strcmp(ext, '.mat')
            continue
        else
            break
        end
    end
        
    file_cont = load( fullfile(mat_dir, file_list{matIdx}) );
    
    FieldLen = numel(file_cont.grp_RR);
    FieldLen = [FieldLen numel(file_cont.Coeff{1}.LL)];
    ColEnergyLen = size(file_cont.Coeff{1}.LL, 2);
    for m = 2:length(file_cont.Coeff)
        FieldLen = [FieldLen, numel(file_cont.Coeff{m}.LH), numel(file_cont.Coeff{m}.HL), numel(file_cont.Coeff{m}.HH) ];
        ColEnergyLen = [ColEnergyLen, size(file_cont.Coeff{m}.LH, 2), ...
            size(file_cont.Coeff{m}.HL, 2), ...
            size(file_cont.Coeff{m}.HH, 2)];
    end
    FieldLen = [FieldLen, ones(1,length(FieldLen)-1), ColEnergyLen]; %length(FieldLen)-1 is the number of subband energies
    
    clear matIdx ext file_cont m
    
    %% Separate Normal and Abnormal Samples
    
    for n = 1:length(file_list)
        [~, ~, ext] = fileparts( fullfile(mat_dir, file_list{n}) );
        
        if ~strcmp(ext, '.mat')
            continue
        end
        
        reg_rslt = regexp(file_list{n},'ID(\d+)_(\d+)','tokens');
        ID = str2double(reg_rslt{1}{1});
        Pic_No = str2double(reg_rslt{1}{2});
        clear reg_rslt
        
        file_cont = load( fullfile(mat_dir, file_list{n}) );
        RR_ = file_cont.grp_RR;
        
        %---Retrieve the Features-----
        Coeff_ = reshape(file_cont.Coeff{1}.LL', 1, []);
        SubEnergy_ = sum(Coeff_.^2, 2)/size(Coeff_,2);
        ColEnergy_ = sum((file_cont.Coeff{1}.LL).^2, 1);
        for m = 2:length(file_cont.Coeff)
            vec_ = reshape(file_cont.Coeff{m}.LH', 1, []);
            SubEnergy_ = [SubEnergy_ sum(vec_.^2, 2)/length(vec_)];
            Coeff_ = [Coeff_, vec_];
            ColEnergy_ = [ColEnergy_, sum((file_cont.Coeff{m}.LH).^2, 1)];
            
            vec_ = reshape(file_cont.Coeff{m}.HL', 1, []);
            SubEnergy_ = [SubEnergy_ sum(vec_.^2, 2)/length(vec_)];
            Coeff_ = [Coeff_, vec_];
            ColEnergy_ = [ColEnergy_, sum((file_cont.Coeff{m}.HL).^2, 1)];
            
            vec_ = reshape(file_cont.Coeff{m}.HH', 1, []);
            SubEnergy_ = [SubEnergy_ sum(vec_.^2, 2)/length(vec_)];
            Coeff_ = [Coeff_, vec_];
            ColEnergy_ = [ColEnergy_, sum((file_cont.Coeff{m}.HH).^2, 1)];
        end
        
        %-----Save the Retrieved Features
        switch file_cont.grp_abnormal
            case 0 %normal
                DataList.Normal = [DataList.Normal; {ID, Pic_No, [RR_ Coeff_ SubEnergy_ ColEnergy_] } ];
            case 1 %abnormal
                DataList.Abnormal = [DataList.Abnormal; {ID, Pic_No, [RR_ Coeff_ SubEnergy_ ColEnergy_] } ];
        end
        clear RR_ Coeff_ SubEnergy_ ColEnergy_
        
    end

    
end