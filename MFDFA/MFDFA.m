
%%  Script to calculate monofractal H & Spectrum width
%  Code from Ihlen et al (2012), adapted for eye-tracking data. 
%  Assumes specific data structure

data = load('/Users/sifre002/Box/sifre002/18-Organized-Code/data/JE000084_04_04/JE000084_04_04_calVerTimeSeries.mat');
session = 'JE000084_04_04';

%% User input:
%Polynomial order for detrending, to be looped through
% M=[2:3]; %m=1(linear); 2(quadratic); 3(cubic)
m=2;
%Total number of segment sizes, to be looped through
% Scres=[4 9];
scres=4;

%MFDFA calculation
q=[-5,-3,-1,0,1,3,5]; % weighting values, btw -5 and 5
Fig=0;

%% Runs MFDFA code
H = [];
calVer =0;
% Pull time series data
fields = fieldnames(data);
if regexp(fields{1}, 'calVer')
    tsdata = getfield(data, 'segmentedData_calVer');
    col = getfield(data, 'calVerCol');
else
    tsdata = getfield(data, 'segmentedData');
    col = getfield(data, 'col');
end

for s = 1:length(tsdata) %loops through time series 
    segment=tsdata{s};
    if ~isempty(segment)
      
   % TO DELETE   
        %determines start and stop of time-series based on longest fix
%         for f=1:length(segment)
%             if f==1 && cell2mat(segment(f,9))==1
%                 fixStart=f;
%             elseif f~=1 && cell2mat(segment(f,9))==1 && cell2mat(segment(f-1,9))==0
%                 fixStart=f;
%             end
%             if f~=1 && f~=length(segment) && cell2mat(segment(f,9))==0 && cell2mat(segment(f-1, 9))==1
%                 fixEnd=f;
%             elseif f==length(segment)==1 && cell2mat(segment(f-1,9))==1
%                 fixEnd=f;
%                 fixEnd=fixEnd-2; %accommodates NaNs at end of data
%             end
%         end


        % Robin added this 
        %fixStart = find(cell2mat(segment(:,9))==1, 1, 'first');
        %fixEnd = find(cell2mat(segment(:,9))==1, 1, 'last');
        
        % 

        %creates time-series based on longest fix, for each type
        longestFix = cell2mat(segment(:, col.longestFixBool));
        amp=cell2mat(segment(longestFix, col.amp));

        %% Pull relevant variables 
        id=segment{1, col.id}; %ID
        movie=segment{1,col.trial}; %movie name
        if (size(segment,2) == 13) % dancing ladies trial - save segment number 
            segNum = segment{1,13};
        else
            segNum = 'NA';
        end
        longestFixDur = segment{1, col.longestFixDur};
        propInterp = segment{1, col.propInterpolated};
        propMissing = segment{1, col.propMissing};
        
        warning=0;
        if length(amp)<1000
            fprintf("Warning: Time series too short"); 
            warning=1;
        end
        if warning==1
            break %breaks loop if time-series is too short
        end
        
        %selects MFDFAa matrix depending on scres (diff dimensions)
        %             if scres==9
        %                 MFDFA1_values={'ID' 'Task' 'H' 'Hq' ' ' ' ' ' ' ' ' ' ' ' ' 'tq' ' ' ' ' ' ' ' ' ' ' ' ' 'hq' ' ' ' ' ' ' ' ' ' ' 'Dq' ' ' ' ' ' ' ' ' ' ' 'Fq' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' 'SpectWidth'};
        %             elseif scres==4
        %                 MFDFA1_values={'ID' 'Task' 'H' 'Hq' ' ' ' ' ' ' ' ' ' ' ' ' 'tq' ' ' ' ' ' ' ' ' ' ' ' ' 'hq' ' ' ' ' ' ' ' ' ' ' 'Dq' ' ' ' ' ' ' ' ' ' ' 'Fq' ' ' ' ' ' ' 'SpectWidth'};
        %             end
        
        
        %% % STEP 2: Run monofractal DFA to check if H is btw 0.2-0.8 (aka if the time-series is noise-like)
        timeSeries=amp;
        %creates scale w/ equal spacing between scales (do before MFDFA1)
        %Matlab code 15------------------------------------------        
        %calculates minimum and maximum segement sizes/scale
        scmin=4; %from prev lit
        scmax=(length(timeSeries)/4);
                
        %creates equal spacing of scale
        exponents=linspace(log2(scmin),log2(scmax),scres);
        scale=round(2.^exponents); %segment sizes
        
        %Scaling function F(ns) computed for multiple segment sizes to
        %account for the differential impacts of fast and slow evolving fluctuations;
        %first, integration--summing area under curve after mean centering
        %RMS{ns}, local fluctuation, is a set of vectors each w/ length equal to number of segments
        %overall RMS calculated here
        %Matlab code 5-------------------------------------------
        X=cumsum(timeSeries-mean(timeSeries));        
        X=transpose(X);
        
        for ns=1:length(scale) %looping through length of scale
            segments(ns)=floor(length(X)/scale(ns)); %# of segments time-series can be divided into
            for v=1:segments(ns)  %loop computes local RMS around a trend fit {v} for each segment
                Idx_start=((v-1)*scale(ns))+1;
                Idx_stop=v*scale(ns);
                Index{v,ns}=Idx_start:Idx_stop;
                X_Idx=X(Index{v,ns});
                C=polyfit(Index{v,ns},X(Index{v,ns}),m);
                fit{v,ns}=polyval(C,Index{v,ns});
                RMS{ns}(v)=sqrt(mean((X_Idx-fit{v,ns}).^2)); %local fluctuation
            end
            F(ns)=sqrt(mean(RMS{ns}.^2)); %overall RMS
        end
        
        %Monofractal structure= power law relation btw overall RMS computed for multiple scales
        %Power law relation btw overalll RMS= slope (H) of regression line, H=Hurst exponent
        %H= how fast overall RMS of local fluctuations grows w/ increasing segment size
        %Uses F (overall RMS)
        %Matlab code 6-------------------------------------------
        C=polyfit(log2(scale),log2(F),1);
        H=C(1); %slope of regression line; see table, p. 15) --0.2-1.2, no conversion needed
        RegLine=polyval(C,log2(scale));
        
        Hlist_list=[Hlist_list;H];
        MFDFA_values{1,9}=H;
        
        vars1 = {'C', 'exponents', 'F', 'fit', 'Index', 'RegLine', 'RMS', 'segments', 'X', 'X_Idx', 'Idx_start', 'Idx_stop', 'ns'};
        clear(vars1{:})
        %%
        %% % STEP 3: Run MFDFA1 (indirect) & MFDFA2 (direct) code
        %     INPUT PARAMETERS---------------------------------------------------------
        %   signal:       input signal
        %   scale:        vector of scales
        %   q:            q-order that weights the local variations
        %   m:            polynomial order for the detrending
        %   Fig:          1/0 flag for output plot of Fq, Hq, tq and multifractal
        %                 spectrum (i.e. Dq versus hq).
        %
        %   MFDFA1 OUTPUT VARIABLES---------------------------------------------------------
        %   Hq:           q-order Hurst exponent
        %   tq:           q-order mass exponent
        %   hq:           q-order singularity exponent
        %   Dq:           q-order dimension
        %   Fq:           q-order scaling function
        
        %  MFDFA2 OUTPUT VARIABLES---------------------------------------------------------
        %   Ht:           Time evolution of the local Hurst exponent
        %   Htbin:        Bin senters for the histogram based estimation of Ph and Dh
        %   Ph:           Probability distribution of the local Hurst exponent Ht
        %   Dh:           Multifractal spectrum
        %
        %scale defined above
        %             q=[-5,-3,-1,0,1,3,5]; % btw -5 and 5
        %             m=3; %m=1(linear); 2(quadratic); 3(cubic)
        %             Fig=1;
        
        %%%%MFDFA1%%%%%
        signal=timeSeries;
        
        %preps data for analysis based on H (noise v. randomwalk nature of input data)
        %based on table on p. 15
        if H<0.2
            signal=cumsum(signal-mean(signal));
        elseif H==1.2 || H<1.8 && H>1.2
            signal=diff(timeSeries);
        elseif H>1.8
            signal=diff(diff(timeSeries));
        end
        
        [Hq, tq, hq, Dq, Fq]= MFDFA1(signal, scale, q, m, Fig);
        
        %calculates indirect multifractal spectrum width
        spectW=max(hq)-min(hq);
        MFDFA_values{1,10}=spectW;
        
        %converts Hq based on conversion table (p. 15)
        if H<0.2
            Hq=Hq-1;
        elseif H==1.2 || H<1.8 && H>1.2
            Hq=Hq+1;
        elseif H>1.8
            Hq=Hq+2;
        end
        
        MFDFA_values(1,12:18)=num2cell(Hq);
        
        %saves MFDFA1 summary figure if Fig=1, but takes a bit of time...
        if Fig==1
            saveas(gcf, strcat(MFDFA1_dir, session, ' Figure 1.jpg'))
            close gcf
        end
        
        %this plot should be linear to indicate scale invariance
        %plots the log of the scale and the log of the RMS
        %                     f=figure('visible', 'off');
        %                     plot(log2(scale),log2(Fq));
        %                     saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,12)),'_', num2str(cell2mat(segment(1,13))), '_log2(scale) v log2(Fq)_', num2str(m), '_', label, '.jpg'))
        %                     clear f
        %
        %plots hq v Dq, or the indirect multifractal spectrum width
        %                     f=figure('visible', 'off');
        %                     plot(hq, Dq);
        %                     saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,10)),'_', num2str(cell2mat(segment(1,11))), '_hq v dq_', num2str(m), '_', label,'.jpg'))
        %                     clear f
        %populates master MFDFA1 data sheet
        %             MFDFA1_values(2,4:10)= num2cell(Hq);
        %             MFDFA1_values(2,11:17)=num2cell(tq);
        %             MFDFA1_values(2,18:23)=num2cell(hq);
        %             MFDFA1_values(2,24:29)=num2cell(Dq);
        
        %allocates a Fq size to match the scale size followed by spectrum width
        %             if scres==9
        %                 MFDFA1_values(2:8,30:38)=num2cell(Fq);
        %                 MFDFA1_values(2,39)=num2cell(spectW);
        %             elseif scres==4
        %                 MFDFA1_values(2:8,30:33)=num2cell(Fq);
        %                 MFDFA1_values(2,34)=num2cell(spectW);
        %
        %             end
        
        %saves out MFDFA1 master data sheet
        %             MFDFA1_values=cell2dataset(MFDFA1_values);
        %             MFDFA1Master=[MFDFA1Master;MFDFA1_values);
        %             export(MFDFA1_values,'file',strcat(MFDFA1_dir, session, ' MFDFA1.csv'),'delimiter',',');
        %
        MFDFA1Master=[MFDFA1Master;MFDFA_values];
        
        %clears MFDFA1 variables
        vars2 = {'Hq','tq','hq', 'Dq','Fq'};
        clear(vars2{:})
        
        %%%%MFDFA2%%%%
        %                     [Ht, Htbin, Ph, Dh]= MFDFA2(signal, scale, m, Fig);
        
        %converts Ht based on conversion table (p. 15)
        %                     if H<0.2
        %                         Ht=Ht-1;
        %                     elseif H==1.2 || H<1.8 && H>1.2
        %                         Ht=Ht+1;
        %                     elseif H>1.8
        %                         Ht=Ht+2;
        %                     end
        %                     clear H
        
        %saves out MFDFA2 outputs separately, as they are all different sizes
        %             csvwrite(strcat(MFDFA2_dir, session, '_Ht.csv'), Ht);
        %             csvwrite(strcat(MFDFA2_dir, session, '_Htbin.csv'), Htbin);
        %             csvwrite(strcat(MFDFA2_dir, session, '_Ph.csv'), Ph);
        %             csvwrite(strcat(MFDFA2_dir, session, '_Dh.csv'), Dh);
        %
        %plots Dh, or the direct multifractal spectrum
        %                     f=figure('visible', 'off');
        %                     plot(Htbin, Dh);
        %                     saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,10)),'_', num2str(cell2mat(segment(1,11))), '_Htbin v Dh_', num2str(m), '_', label,'.jpg'))
        %                     clear f
        
        %plots probability distribution of Ph, showing temporal
        %variation of Ht
        %                     f=figure('visible', 'off');
        %                     plot(Htbin, Ph);
        %                     saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,10)),'_', num2str(cell2mat(segment(1,11))), '_Htbin v Ph_', num2str(m), '_', label,'.jpg'))
        %                     clear f
        
        %saves out MFDFA2 summary figure if Fig=1; this one takes a long time
        if Fig==1
            saveas(gcf, strcat(MFDFA2_dir, session, ' Figure 2.jpg'))
            close gcf
        else
        end
        
        %clears MFDFA2 variables
        vars3={'Ht', 'Htbin', 'Ph', 'Dh', 'v', 'scale','signal','z'};
        clear(vars3{:})
        %
        
        %the scales that are not constant = segment size above and below which
        %RMS are no longer scale invariant
        % plot(log2(scale),log2(Fq(q==1,:)./scale))
        
        %clears MFDFA1 variables
        vars2 = {'z','signal','Hq','tq','hq', 'Dq','Fq', 'scale'};
        clear(vars2{:})
        
        %clears MFDFA2 variables
        vars3={'Ht', 'Htbin', 'Ph', 'Dh', 'v'};
        clear(vars3{:})
        %
        clear MFDFA_values
        
        clear amp
    end
    
end
clear data


end

clear segmentedData
clear calVerTimeSeries
clear segment





%saves out a list of monofractal H's for each task (for a sanity check)
%     csvwrite(output_dir, '_H-list_', num2str(m), '.csv', Hlist_list);

MFDFA=cell2table(MFDFA1Master);
writetable(MFDFA, strcat(output_dir,'Master_MFDFA_DL.xlsx'));

% csvwrite(output_dir,'MFDFA_Master.csv', MFDFA1Master);

% xlswrite(strcat(output_dir, 'masterConcatMFDFA.xlsx'), mf);


