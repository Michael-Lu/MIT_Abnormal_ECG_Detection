clc;
clear all;

%SAVEDFILENAME= [203];%------for test
SAVEDFILENAME= [100 101 103 105 106 108 109 111:119 121:124 200:203 205 207:210 212:215 219:223 228 230:234];
% SAVEDFILENAME= [102 104 107 217];  %pacemaker ECGs
QRSLENGTH= 200;
ALLANNTYPE= 0;

ErrorList = [];

for FILENUM = 1:size(SAVEDFILENAME,2)
%     TARGETLEAD= 1;
%     if(SAVEDFILENAME(FILENUM) == 114)
%         TARGETLEAD= 2;
%     end
%     %%
%     %%----------READING BINARY DATA (M)----------%%
%     %------ SPECIFY DATA ------------------------------------------------------
%     PATH= 'D:\ECG_Wavelet_Decoder_Sim\MIT\MIT-BIH arrhythmia database'; % path, where data are saved
%     HEADERFILE = [num2str(SAVEDFILENAME(FILENUM)),'.hea'];      % header-file in text format
%     ATRFILE = [num2str(SAVEDFILENAME(FILENUM)),'.atr'];         % attributes-file in binary format
%     DATAFILE = [num2str(SAVEDFILENAME(FILENUM)),'.dat'];         % data-file
%     SAMPLES2READ=650000;        % number of samples to be read; in case of more than one signal:2*SAMPLES2READ samples are read
%     %------ LOAD HEADER DATA --------------------------------------------------
%     fprintf(1,'\\n$> WORKING ON %s ...\n', num2str(SAVEDFILENAME(FILENUM)));
%     signalh= fullfile(PATH, HEADERFILE);
%     fid1=fopen(signalh,'r');
%     z= fgetl(fid1);
%     A= sscanf(z, '%*s %d %d %d',[1,3]);
%     nosig= A(1);  % number of signals
%     sfreq=A(2);   % sample rate of data
%     clear A;
%     for k=1:nosig
%         z= fgetl(fid1);
%         A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
%         dformat(k)= A(1);           % format; here only 212 is allowed
%         gain(k)= A(2);              % number of integers per mV
%         bitres(k)= A(3);            % bitresolution
%         zerovalue(k)= A(4);         % integer value of ECG zero point
%         firstvalue(k)= A(5);        % first integer value of signal (to test for errors)
%     end;
%     fclose(fid1);
%     clear A;
%     %------ LOAD BINARY DATA --------------------------------------------------
%     if dformat~= [212,212], error('this script does not apply binary formats different to 212.'); end;
%     signald= fullfile(PATH, DATAFILE);            % data in format 212
%     fid2=fopen(signald,'r');
%     A= fread(fid2, [3, SAMPLES2READ], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit
%     fclose(fid2);
%     M2H= bitshift(A(:,2), -4);
%     M1H= bitand(A(:,2), 15);
%     PRL=bitshift(bitand(A(:,2),8),9);     % sign-bit
%     PRR=bitshift(bitand(A(:,2),128),5);   % sign-bit
%     M( : , 1)= bitshift(M1H,8)+ A(:,1)-PRL;
%     M( : , 2)= bitshift(M2H,8)+ A(:,3)-PRR;
%     if M(1,:) ~= firstvalue, error('inconsistency in the first bit values'); end;
%     switch nosig
%         case 2
%             M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
%             M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
%             TIME=(0:(SAMPLES2READ-1))/sfreq;
%         case 1
%             M( : , 1)= (M( : , 1)- zerovalue(1));
%             M( : , 2)= (M( : , 2)- zerovalue(1));
%             M=M';
%             M(1)=[];
%             sM=size(M);
%             sM=sM(2)+1;
%             M(sM)=0;
%             M=M';
%             M=M/gain(1);
%             TIME=(0:2*(SAMPLES2READ)-1)/sfreq;
%         otherwise  % this case did not appear up to now!
%             % here M has to be sorted!!!
%             disp('Sorting algorithm for more than 2 signals not programmed yet!');
%     end;
%     clear A M1H M2H PRR PRL;
%     
%     %------ LOAD ATTRIBUTES DATA ----------------------------------------------
%     atrd= fullfile(PATH, ATRFILE);      % attribute file with annotation data
%     fid3=fopen(atrd,'r');
%     A= fread(fid3, [2, inf], 'uint8')';
%     fclose(fid3);
%     ATRTIME=[];
%     ANNOT=[];
%     RHYTHMS= [];
%     sa=size(A);
%     saa=sa(1);
%     i=1;
%     while i<=saa
%         annoth=bitshift(A(i,2),-2);
%         if annoth==59
%             ANNOT=[ANNOT;bitshift(A(i+3,2),-2)];
%             ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
%                 bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
%             i=i+3;
%         elseif annoth==60
%             % nothing to do!
%         elseif annoth==61
%             % nothing to do!
%         elseif annoth==62
%             % nothing to do!
%         elseif annoth==63
%             hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
%             hilfe=hilfe+mod(hilfe,2);
%             %---Saving the RHYTHMS---%
%             Rm= hilfe/2;
%             RHYTHMINDEX= cumsum(ATRTIME);
%             RHYTHM= [RHYTHMINDEX(end),reshape(A(i+1:i+1+Rm-1,:)',1,numel(A(i+1:i+1+Rm-1,:)))];
%             RHYTHM(8)= 0;
%             RHYTHMS= [RHYTHMS;RHYTHM];
%             %------------------------%
%             i=i+hilfe/2;
%         else
%             ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
%             ANNOT=[ANNOT;bitshift(A(i,2),-2)];
%         end;
%         i=i+1;
%     end;
%     ANNOT(length(ANNOT))=[];       % last line = EOF (=0)
%     ATRTIME(length(ATRTIME))=[];   % last line = EOF
%     clear A;
%     ATRTIME= cumsum(ATRTIME);
%     ind= find(ATRTIME <= SAMPLES2READ);
%     ATRTIMED= ATRTIME(ind); %---R-peaks & time of annotation
%     ANNOT= round(ANNOT);
%     ANNOTD= ANNOT(ind); %---annotation of beat type
%     %% Preprocessing
%     % filter parameter setting
%     % LPF: passband_cutfreq=40,stopband_cutfreq=50
%     % HPF: passband_cutfreq=10,stopband_cutfreq=0.1
%     % ripple in passband less than 3dB,attenuation in stopband at least 20dB
%     Wp_low = 40/(sfreq/2); Ws_low = 50/(sfreq/2);
%     Wp_high = 10/(sfreq/2); Ws_high = 0.1/(sfreq/2);
%     Rp = 3; Rs = 20;
%     
%     [n_low,Wn_low] = buttord(Wp_low,Ws_low,Rp,Rs);
%     [b,a] = butter(n_low,Wn_low,'low');
%     [A,f_low]=freqz(b,a,SAMPLES2READ,sfreq);
%     [n_high,Wn_high] = buttord(Wp_high,Ws_high,Rp,Rs);
%     [d,c] = butter(n_high,Wn_high,'high');
%     [B,f_high]=freqz(d,c,SAMPLES2READ,sfreq);
%     
%     %     figure;freqz(b,a,SAMPLES2READ,sfreq);
%     %     figure;freqz(d,c,SAMPLES2READ,sfreq);
%     %     figure;
%     %     subplot(1,2,1);plot(f_low,abs(A));grid;xlabel('Frequency (Hz)');
%     %     subplot(1,2,2);plot(f_high,abs(B));grid;xlabel('Frequency (Hz)');
%     
%     %%
%     in_sign=M(:,TARGETLEAD);
%     out_sign1=filter(b,a,in_sign);
%     out_sign2=filter(d,c,out_sign1);
%     
%     freq_in  =abs(fft(in_sign));
%     freq_out1=abs(fft(out_sign1));
%     freq_out2=abs(fft(out_sign2));
%     
%     %     figure;hold on;
%     %     subplot(2,3,1);title('input signal');plot(in_sign(100:2000));grid on;
%     %     subplot(2,3,2);title('output signal');plot(out_sign1(100:2000));grid on;
%     %     subplot(2,3,3);title('output signal');plot(out_sign2(100:2000));grid on;
%     %     subplot(2,3,4);title('input signal frequency response');plot(freq_in);grid on;
%     %     subplot(2,3,5);title('output signal frequency response');plot(freq_out1);grid on;
%     %     subplot(2,3,6);title('output signal frequency response');plot(freq_out2);grid on;
%     %     close all;
%     
%     
%     %%
%     %save all samples & annotations with sample points
%     ALLS_lead1= out_sign2;
%     ANNOT_TIME= [ATRTIMED,ANNOTD];
     SAVED_ADD_1= fullfile(pwd,'retrieved_ECG');
%     save([SAVED_ADD_1,num2str(SAVEDFILENAME(FILENUM)),'.mat'],'ALLS_lead1','ANNOT_TIME','RHYTHMS');
%     %%
%     
%     SAVED_ADD_2= fullfile(pwd,'ECG_SEPARATED_BY_BEAT_WITH_NONPACEMAKER\'); %The dir where we put the separated out ECG segments
%     
%     if ~exist(SAVED_ADD_2,'dir')
%         mkdir(SAVED_ADD_2);
%     end
%     
    
%%

    load([SAVED_ADD_1,num2str(SAVEDFILENAME(FILENUM)),'.mat'])
    try
        Annotation = Filter_Anno(ANNOT_TIME, union(1:13, [31,34,37] ) );

        [ECG_Signal, Annotation, offset] = trim_ECG(ALLS_lead1, Annotation);

        [RR segments beat]  = chop_ECG(ECG_Signal, Annotation);
        
        %save([SAVED_ADD_2, 'ID_', num2str(SAVEDFILENAME(FILENUM) ) ], 'RR', 'segments', 'beat');

        [~] = seg2mat(RR, segments, beat, fullfile(pwd,'image_mat_2'), ['ID', num2str( SAVEDFILENAME(FILENUM) ), '_'] );

    catch err
        ErrorList = [ ErrorList; {FILENUM,err}];
        continue
    end

                
    fprintf(1,'\\n$> %s PROCESSING WAS FINISHED \n', num2str(SAVEDFILENAME(FILENUM)) );
end

if ~isempty(ErrorList)
   ErrorList
end

fprintf(1,'\\n$> ALL FINISHED \n');


