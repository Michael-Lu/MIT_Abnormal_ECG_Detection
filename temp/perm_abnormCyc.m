function [ perm_idx ] = perm_abnormCyc( seg_beats )
% Permute the row index of the ECG image, to rearrange the positions of
% abnormal cycles
%   We don't change the original position of the normal cycles but change
%   the abnormal cylces to every possible positions.
    
    abnorm_idx = find(seg_beats~=1);
    norm_idx = setdiff(1:length(seg_beats), abnorm_idx );
    
    abnorm_pos = nchoosek(1:length(seg_beats), length(abnorm_idx));
    abnorm_idx_perm = perms(abnorm_idx);
    
    perm_idx = [];
    for n = 1:size(abnorm_pos,1)
        img_idx = zeros(1,length(seg_beats));
        for m = 1:size(abnorm_idx_perm,1)
            img_idx(abnorm_pos(n,:)) = abnorm_idx_perm(m,:);
            img_idx(setdiff(1:length(seg_beats), abnorm_pos(n,:) ) ) = norm_idx;
            perm_idx = [perm_idx; img_idx];
        end
    end
    
end

