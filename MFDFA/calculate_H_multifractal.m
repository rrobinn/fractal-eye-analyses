function [Hq, tq, hq, Dq, Fq, spectW] = calculate_H_multifractal(ts, H)
% output: spectW, Hq, tq, hq, Dq, Fq
Fig = 0; % flag for including figs 
%%%%MFDFA1%%%%%
signal=ts;

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

%converts Hq based on conversion table (p. 15)
if H<0.2
    Hq=Hq-1;
elseif H==1.2 || H<1.8 && H>1.2
    Hq=Hq+1;
elseif H>1.8
    Hq=Hq+2;
end

%saves MFDFA1 summary figure if Fig=1, but takes a bit of time...
% if Fig==1
%     saveas(gcf, strcat(MFDFA1_dir, session, ' Figure 1.jpg'))
%     close gcf
% end

%this plot should be linear to indicate scale invariance
%plots the log of the scale and the log of the RMS
% f=figure('visible', 'off');
% plot(log2(scale),log2(Fq));
% saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,12)),'_', num2str(cell2mat(segment(1,13))), '_log2(scale) v log2(Fq)_', num2str(m), '_', label, '.jpg'))
% clear f
% 
% plots hq v Dq, or the indirect multifractal spectrum width
% f=figure('visible', 'off');
% plot(hq, Dq);
% saveas(f, strcat(MFDFA1_dir, session, '_',cell2mat(segment(1,10)),'_', num2str(cell2mat(segment(1,11))), '_hq v dq_', num2str(m), '_', label,'.jpg'))
% clear f
% populates master MFDFA1 data sheet




%saves out MFDFA1 master data sheet
%             MFDFA1_values=cell2dataset(MFDFA1_values);
%             MFDFA1Master=[MFDFA1Master;MFDFA1_values);
%             export(MFDFA1_values,'file',strcat(MFDFA1_dir, session, ' MFDFA1.csv'),'delimiter',',');
%



%%
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