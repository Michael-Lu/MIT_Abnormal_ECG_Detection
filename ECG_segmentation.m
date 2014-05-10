function [Data_table]=ECG_segmentation(ECG_data_path,Class_beat,QRS_length,Do_pre)
% ECG_data_path 是讀 .hea,.atr,.dat的資料夾位置 ex:'address'
% ECG_records 是欲使用之record編號 ex:[100 101 103 .....]
% QRS_length 是QRS波切割的長度 ex:64
% Do_pre 是否要做preprocessing ex: 1要;0不要
% Data_table 是MIT-BIH arrhythmia Database的beats資訊
ALLANNTYPE= 0;
ECG_records= unique(Class_beat(:,2));
for FILENUM = 1:size(ECG_records,1)
    TARGETLEAD= 1;
    if(ECG_records(FILENUM) == 114)
        TARGETLEAD= 2;
    end
    %% READING BINARY DATA (M)
    %------ SPECIFY DATA ------------------------------------------------------
    HEADERFILE = [num2str(ECG_records(FILENUM)),'.hea'];      % header-file in text format
    ATRFILE = [num2str(ECG_records(FILENUM)),'.atr'];         % attributes-file in binary format
    DATAFILE = [num2str(ECG_records(FILENUM)),'.dat'];         % data-file
    SAMPLES2READ=650000;        % number of samples to be read; in case of more than one signal:2*SAMPLES2READ samples are read
    %------ LOAD HEADER DATA --------------------------------------------------
    fprintf(1,'%s SEGMENTATION ...\n', num2str(ECG_records(FILENUM)));
    signalh= fullfile(ECG_data_path, HEADERFILE);
    fid1=fopen(signalh,'r');
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d',[1,3]);
    nosig= A(1);  % number of signals
    sfreq=A(2);   % sample rate of data
    clear A;
    for k=1:nosig
        z= fgetl(fid1);
        A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
        dformat(k)= A(1);           % format; here only 212 is allowed
        gain(k)= A(2);              % number of integers per mV
        bitres(k)= A(3);            % bitresolution
        zerovalue(k)= A(4);         % integer value of ECG zero point
        firstvalue(k)= A(5);        % first integer value of signal (to test for errors)
    end;
    fclose(fid1);
    clear A;
    %------ LOAD BINARY DATA --------------------------------------------------
    if dformat~= [212,212], error('this script does not apply binary formats different to 212.'); end;
    signald= fullfile(ECG_data_path, DATAFILE);            % data in format 212
    fid2=fopen(signald,'r');
    A= fread(fid2, [3, SAMPLES2READ], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit
    fclose(fid2);
    M2H= bitshift(A(:,2), -4);
    M1H= bitand(A(:,2), 15);
    PRL=bitshift(bitand(A(:,2),8),9);     % sign-bit
    PRR=bitshift(bitand(A(:,2),128),5);   % sign-bit
    M( : , 1)= bitshift(M1H,8)+ A(:,1)-PRL;
    M( : , 2)= bitshift(M2H,8)+ A(:,3)-PRR;
    if M(1,:) ~= firstvalue, error('inconsistency in the first bit values'); end;
    switch nosig
        case 2
            M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
            M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
            TIME=(0:(SAMPLES2READ-1))/sfreq;
        case 1
            M( : , 1)= (M( : , 1)- zerovalue(1));
            M( : , 2)= (M( : , 2)- zerovalue(1));
            M=M';
            M(1)=[];
            sM=size(M);
            sM=sM(2)+1;
            M(sM)=0;
            M=M';
            M=M/gain(1);
            TIME=(0:2*(SAMPLES2READ)-1)/sfreq;
        otherwise  % this case did not appear up to now!
            % here M has to be sorted!!!
            disp('Sorting algorithm for more than 2 signals not programmed yet!');
    end;
    clear A M1H M2H PRR PRL;
    
    %------ LOAD ATTRIBUTES DATA ----------------------------------------------
    atrd= fullfile(ECG_data_path, ATRFILE);      % attribute file with annotation data
    fid3=fopen(atrd,'r');
    A= fread(fid3, [2, inf], 'uint8')';
    fclose(fid3);
    ATRTIME=[];
    ANNOT=[];
    RHYTHMS= [];
    sa=size(A);
    saa=sa(1);
    i=1;
    while i<=saa
        annoth=bitshift(A(i,2),-2);
        if annoth==59
            ANNOT=[ANNOT;bitshift(A(i+3,2),-2)];
            ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
            i=i+3;
        elseif annoth==60
            % nothing to do!
        elseif annoth==61
            % nothing to do!
        elseif annoth==62
            % nothing to do!
        elseif annoth==63
            hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
            hilfe=hilfe+mod(hilfe,2);
            %---Saving the RHYTHMS---%
            Rm= hilfe/2;
            RHYTHMINDEX= cumsum(ATRTIME);
            RHYTHM= [RHYTHMINDEX(end),reshape(A(i+1:i+1+Rm-1,:)',1,numel(A(i+1:i+1+Rm-1,:)))];
            RHYTHM(8)= 0;
            RHYTHMS= [RHYTHMS;RHYTHM];
            %------------------------%
            i=i+hilfe/2;
        else
            ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
            ANNOT=[ANNOT;bitshift(A(i,2),-2)];
        end;
        i=i+1;
    end;
    ANNOT(length(ANNOT))=[];       % last line = EOF (=0)
    ATRTIME(length(ATRTIME))=[];   % last line = EOF
    clear A;
    ATRTIME= cumsum(ATRTIME);
    ind= find(ATRTIME <= SAMPLES2READ);
    ATRTIMED= ATRTIME(ind); %---R-peaks & time of annotation
    ANNOT= round(ANNOT);
    ANNOTD= ANNOT(ind); %---annotation of beat type
    
    %% Preprocessing
    if Do_pre == 1
        % filter parameter setting
        % LPF: passband_cutfreq=40,stopband_cutfreq=50
        % HPF: passband_cutfreq=10,stopband_cutfreq=0.1
        % ripple in passband less than 3dB,attenuation in stopband at least 20dB
        Wp_low = 40/(sfreq/2); Ws_low = 50/(sfreq/2);
        Wp_high = 10/(sfreq/2); Ws_high = 0.1/(sfreq/2);
        Rp = 3; Rs = 20;
        [n_low,Wn_low] = buttord(Wp_low,Ws_low,Rp,Rs);
        [b,a] = butter(n_low,Wn_low,'low');
        [n_high,Wn_high] = buttord(Wp_high,Ws_high,Rp,Rs);
        [d,c] = butter(n_high,Wn_high,'high');
        % filting for removing base-line
        in_sign = M(:,TARGETLEAD);
        out_sign1 = filter(b,a,in_sign);
        ALLS_lead1 = filter(d,c,out_sign1);
    else
        ALLS_lead1= M(:,TARGETLEAD);
    end
    %% save all samples & annotations with sample points
    ANNOT_TIME= [ATRTIMED,ANNOTD];
    %     save([num2str(ECG_records(FILENUM)),'.mat'],'ALLS_lead1','ANNOT_TIME','RHYTHMS');
    %% separating beat types-------------------------------
    ANNTYPE= unique(ANNOTD);%beat types of record
    for NOANNTYPE= 1:length(ANNTYPE)
        FIRST_R= [];
        ANNOTINDEX= ATRTIMED(ANNOTD== ANNTYPE(NOANNTYPE));%R peak's sample point of this beat type
        ANNOTINDEX= ANNOTINDEX(ANNOTINDEX > (QRS_length/2));%R peak sample point bigger than QRS_length/2
        ANNOTINDEX= ANNOTINDEX(ANNOTINDEX < SAMPLES2READ - (QRS_length/2) + 1);%R peak sample point smller than (SAMPLES2READ - QRS_length/2 + 1)
        RR=[];
        if ~isempty(ANNOTINDEX)
            for NOANNOT= 1:length(ANNOTINDEX)
                R_INDEX= find(ATRTIMED==ANNOTINDEX(NOANNOT));%memorry address of R peak
                if ANNOTINDEX(NOANNOT) ~= ATRTIMED(1)
                    RR(NOANNOT,1)= ATRTIMED(R_INDEX)  - ATRTIMED(R_INDEX-1);
                    if Do_pre==1
                        PARTQRS_DC= ALLS_lead1((ANNOTINDEX(NOANNOT))-(QRS_length/2):ANNOTINDEX(NOANNOT)+(QRS_length/2)-1)';
                        PARTQRS(NOANNOT,:)= PARTQRS_DC-mean(PARTQRS_DC);
                    else
                        PARTQRS(NOANNOT,:)= ALLS_lead1((ANNOTINDEX(NOANNOT))-(QRS_length/2):ANNOTINDEX(NOANNOT)+(QRS_length/2)-1)';
                    end
                    ALLANNTYPE= union(ALLANNTYPE,ANNTYPE(NOANNTYPE));
                else
                    FIRST_R= 1;
                end
            end
            if ~isempty(RR)
                save([num2str(ECG_records(FILENUM)),'_',num2str(ANNTYPE(NOANNTYPE)),'.mat'],'PARTQRS','RR');
                clear PARTQRS RR
            end
        end
        if ~isempty(FIRST_R)
            ANNOTINDEX= ANNOTINDEX(2:end);
        end
        if ANNTYPE(NOANNTYPE)==1||ANNTYPE(NOANNTYPE)==2||ANNTYPE(NOANNTYPE)==3||ANNTYPE(NOANNTYPE)==4||ANNTYPE(NOANNTYPE)==5||...
            ANNTYPE(NOANNTYPE)==6||ANNTYPE(NOANNTYPE)==8||ANNTYPE(NOANNTYPE)==10||ANNTYPE(NOANNTYPE)==11||ANNTYPE(NOANNTYPE)==12||...
            ANNTYPE(NOANNTYPE)==31||ANNTYPE(NOANNTYPE)==37||ANNTYPE(NOANNTYPE)==38
        Data_table(FILENUM,ANNTYPE(NOANNTYPE))= length(ANNOTINDEX);  
        end
    end
    
    
end
Data_table= Data_table(:,sum(Data_table,1)~=0);
Data_table= [[0 1 2 3 4 5 6 8 10 11 12 31 37 38]; ECG_records Data_table; 0 sum(Data_table,1) ];
fprintf(1,'SEGMENTATION FINISHED************ \n');