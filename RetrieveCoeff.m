function err = RetrieveCoeff(jasper_path, tmpfile_working_dir, mat_dir, jasper_enc_options)
    err = 0;
    
    if(nargin ~=3 && nargin ~=4 )
        throw(MException('RetrieveCoeff:WrongInputNum', 'Wrong number of input arguments, threre''re %d inputs now.', nargin));
    end

    if(nargin == 3)
        jasper_enc_options = [];
    end

    if ~exist(jasper_path, 'file')
        throw(MException('RetrieveCoeff:PathError', 'Cannot find decoder: %s', jasper_path));
    end
    
    if ~exist(tmpfile_working_dir, 'dir')
        [success, ~, ~] = mkdir(tmpfile_working_dir);
        if ~success
            throw(MException('RetrieveCoeff:PathError', 'Cannot find temp working dir: %s', tmpfile_working_dir));
        end
    end
    
    if ~exist(mat_dir, 'dir')
        throw(MException('RetrieveCoeff:PathError', 'Cannot find mat_dir: %s', mat_dir));
    end
    
    origi_working_dir = pwd;
    cd(tmpfile_working_dir);
    
    file_list = ls(mat_dir);
    
    for n = 1 : size(file_list,1)
        [~, name, ext] = fileparts( deblank(file_list(n,:)) );
        
        if ~strcmp(ext,'.mat') %do not deal with file of which the type is not 'mat' 
            continue
        end
        
        fileCont = load( fullfile(mat_dir, deblank(file_list(n,:) ) ) );
        
        bmpPath = fullfile(tmpfile_working_dir, [name '.bmp'] );
        jp2Path = fullfile(tmpfile_working_dir, [name '.jp2'] );
        imwrite(fileCont.image, bmpPath);
        
        command= [jasper_path, ' -f "', bmpPath, '" -F "', jp2Path, '" ' jasper_enc_options];
        system(command);
        
        command= [jasper_path, ' -f "', jp2Path, '" -F "', bmpPath, '"'];
        system(command);
        
        delete(bmpPath);
        delete(jp2Path);
        
        Coeff_file_list = ls(fullfile(tmpfile_working_dir, name) );
        for m = 1 : size(Coeff_file_list,1)
            [~, coeff_name, coeff_ext] = fileparts( fullfile(tmpfile_working_dir, name, deblank(Coeff_file_list(m,:)) ) );
            
            if ~strcmp(coeff_ext,'.txt') %do not deal with file of which the type is not 'txt' 
                continue
            end
            
            rslv = sscanf(coeff_name,'Coeff%d_%d');
            band = rslv(2);
            rslv = rslv(1)+1;
            
            band_cont = load( fullfile(tmpfile_working_dir, name, deblank(Coeff_file_list(m,:)) ) );
            
            if ~isempty(band_cont)
                switch band
                    case 0
                        Coeff{rslv}.LL = band_cont;
                    case 1
                        Coeff{rslv}.LH = band_cont;
                    case 2
                        Coeff{rslv}.HL = band_cont;
                    case 3
                        Coeff{rslv}.HH = band_cont;
                end
            else
                switch band
                    case 0
                        Coeff{rslv}.LL = [];
                    case 1
                        Coeff{rslv}.LH = [];
                    case 2
                        Coeff{rslv}.HL = [];
                    case 3
                        Coeff{rslv}.HH = [];
                end
                
            end
            
            clear band_cont rslv band rslv coeff_ext coeff_name
        end
        
        save( fullfile(mat_dir, deblank(file_list(n,:)) ), 'Coeff', '-append')
        rmdir(fullfile(tmpfile_working_dir,name), 's' );
    end
    
    cd(origi_working_dir);
          
end