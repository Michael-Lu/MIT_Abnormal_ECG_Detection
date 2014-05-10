function [ SampleInfo ] = ListSampleInfo( SampleList, mat_dir )
% List out the information of samples according to the SampleList

    SampleInfo = [];
    for n = 1:size(SampleList,1)
        PerID = SampleList{n,1};
        ImgIdx = SampleList{n,2};
        fileCont = load(fullfile(mat_dir,['ID', num2str(PerID), '_', num2str(ImgIdx), '.mat']) );
        SampleInfo = [SampleInfo; {PerID, ImgIdx, setdiff(unique(fileCont.seg_beat),[1])}];
    end


end

