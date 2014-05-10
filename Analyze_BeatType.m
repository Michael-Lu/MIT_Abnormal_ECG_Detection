function beatTypes = Analyze_BeatType(Image_List, mat_path)

    if ~exist(mat_path,'dir')
        throw(MException('mat_path does not exist'));
    end
    
    beatTypes = [];
    for m = 1:size(Image_List,1)
        file_name_pattern = fullfile(mat_path, ['ID' num2str(Image_List(m,1)) '_' num2str(Image_List(m,2)) '.mat']);
        file_cont = load(file_name_pattern);
        beatTypes = union(beatTypes, file_cont.seg_beat);
    end
end
