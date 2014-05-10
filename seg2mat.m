function [num_mat] = seg2mat(RR, segments, beat, image_output_dir, file_prefix)

    if ~exist(image_output_dir,'dir')
        mkdir(image_output_dir)
    end
    
    num_mat = ( length(RR)-mod(length(RR),10) )/10;
    
    for m = 1: 10 : num_mat*10
        for n = 1:10
            ECG_Matrix(n,:)= interp1(1:RR(m+n-1), segments{m+n-1}', 1:(RR(m+n-1)-1)/199:RR(m+n-1), 'linear');
        end
        
        min_v = min(min(ECG_Matrix));
        max_v = max(max(ECG_Matrix));
        image = uint8( (ECG_Matrix-min_v).*255./(max_v-min_v) ); 
        
        %grp_beats = beat(m:m+9);
        grp_RR = RR(m:m+9);
        seg_beat = beat(m:m+9);
        grp_abnormal = sum(seg_beat~=1) > 0;
        
        save(fullfile(image_output_dir, [file_prefix, num2str( ceil(m/10) )] ), 'image', 'grp_RR', 'grp_abnormal', 'seg_beat', '-append');
    end
    clear seg_beat
end