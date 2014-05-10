function [ DataList, FieldLen ] = GatherFeatures_Perms_Caller( data_base_dir )
% Apply GatherFeatures_Perms() to each person's images.
    
    dir_list = ls(data_base_dir);
    rm_list = [];
    for n = 1:size(dir_list,1)
        if strcmp(deblank(dir_list(n,:)), '.')
            rm_list = [rm_list, n];
        end
        
        if strcmp(deblank(dir_list(n,:)), '..')
            rm_list = [rm_list, n];
        end
    end
    dir_list(rm_list,:)=[];
    clear rm_list
    
    DataList.Normal = [];
    DataList.Abnormal = [];
    for n = 1:size(dir_list,1)
        [PerDataList FieldLen] = GatherFeatures_Perm( fullfile(data_base_dir, deblank(dir_list(n,:)) ) );
        %Deal with Normal Data
        if ~isempty(PerDataList.Normal)
            
            imgIdx = cell2mat( PerDataList.Normal(:,2) );
            imgList = unique(imgIdx);
            perID = str2double(dir_list(n,4:end) );
            for m = 1:size(imgList,1)
                DataList.Normal = [ DataList.Normal; { perID, {imgList(m), DataListPerDataList.Normal(imgIdx == imgList(m), 3) } }];
            end
        end
        
        
        %Deal with Abnormal Data
        if ~isempty(PerDataList.Abnormal)
            
            imgIdx = cell2mat( PerDataList.Abnormal(:,2) );
            imgList = unique(imgIdx);
            perID = str2double(dir_list(n,4:end) );
            for m = 1:size(imgList,1)
                DataList.Abnormal = [ DataList.Abnormal; { perID, {imgList(m), PerDataList.Abnormal(imgIdx == imgList(m), 3) } }];
            end
        end
    end
    


end

