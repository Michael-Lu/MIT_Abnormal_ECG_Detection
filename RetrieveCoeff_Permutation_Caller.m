function err = RetrieveCoeff_Permutation_Caller(jasper_path, tmpfile_working_dir, mat_dir, jasper_enc_options)
% Call the RetrieveCoeff_Permutation() function
% Process the Image in each folder as a unit

    dir_list = ls(mat_dir)
    rm_list = [];
    for n = 1 : size(dir_list,1)

        if strcmp( deblank(dir_list(n,:)),'.') %do not deal with file of which the type is not 'mat' 
            rm_list = [rm_list, n];
            continue
        end

        if strcmp( deblank(dir_list(n,:)),'..') %do not deal with file of which the type is not 'mat' 
            rm_list = [rm_list, n];
            continue
        end

    end
    dir_list(rm_list, :)= [];
    clear rm_list

    for dirIter = 1:size(dir_list,1)
        tic
        comp_ration = 100*dirIter/size(dir_list,1);
        display(['Processing', dir_list(dirIter,:), '...'] );
        
        err = RetrieveCoeff_Permutation(jasper_path, tmpfile_working_dir, fullfile(mat_dir, deblank(dir_list(dirIter,:) ) ), jasper_enc_options);
        
        display(['...', num2str(comp_ration), ' Completed.....']);
        toc
    end

end

