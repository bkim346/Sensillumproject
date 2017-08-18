function plotresp(prefix, eagchan, LFPchan, ntrials, bdndx, respchan, stimchan, fs)

% plotresp(prefix, eagchan, LFPchan, ntrials, bdndx, respchan, stimchan, fs)
%
% Function to plot all response trials for physiology data in separate
% panels in a single figure
% Inputs:
% prefix- prefix of recording to analyze
% eagchan- index of channel containing eag voltage (default=3)
% LFPchan- index of channel containing lfp voltage (default=4)
% ntrials- total number of trials in recording (default=5)
% bdndx- index of which trials to skip for analysis (default=[])
% respchan- index of channel containing spiking data (default=1)
% stimchan- index of channel containing stim voltage (default=2)
% fs- sample rate of recording in cycles/sec (default=1e4)
%
% July 6th 2017, AK
% July 21st 2017, Bk - edited
%  - Added LFP channel plot with right side axis and matched plot colors to
%  axis
%  - Updated Description

% Default
if nargin<1||isempty(prefix)
    prefix=uigetfile('*.*', 'Choose Prefix File');
    prefix=prefix(1:end-7);
end
if nargin<2||isempty(eagchan), eagchan=[]; end
if nargin<3||isempty(LFPchan), LFPchan=[]; end
if nargin<4||isempty(ntrials), ntrials=5; end
if nargin<5||isempty(bdndx), bdndx=[]; end
if nargin<6||isempty(respchan), respchan=1; end
if nargin<7||isempty(stimchan), stimchan=2; end
if nargin<8||isempty(fs), fs=1e4; end
gain=5000; %default gain used to record spikes
ttrials=ntrials-length(bdndx);

%Spiking channel
data=parseOneChannel('.',prefix,ntrials,bdndx,respchan)*10000000/pow2(16)/gain;
%Stim channel
datas=parseOneChannel('.',prefix,ntrials,bdndx,stimchan)*10/pow2(16);
%EAG channel
if ~isempty(eagchan)
    datae=-parseOneChannel('.',prefix,ntrials,bdndx,eagchan)*10000/pow2(16)/500;
    for ind=1:ttrials
        datae(ind,:)=datae(ind,:)-median(datae(ind,end-fs:end));
    end
end
%LFP channel , gain at 500 (Last number)
if ~isempty(LFPchan)
    datal=-parseOneChannel('.',prefix,ntrials,bdndx,LFPchan)*10000/pow2(16)/500;
    for ind=1:ttrials
        datal(ind,:)=nitinfilt_low(datal(ind,:),10,fs); %get rid of spikes
        datal(ind,:)=datal(ind,:)-median(datal(ind,end-fs:end));
    end
end


tv=(1:length(data))/fs;
figure
set(gcf,'Pos', [450 90 560 900])
yl=zeros(ttrials,2);
y2=zeros(ttrials,2);

%Plot all physiology data
for ind=1:(ttrials)
    subplot(ttrials,1,ind)
    plot(tv,data(ind,:), 'color', [36, 126, 214]./256, 'LineWidth', 1)
    hold on
    if ind==1, title(prefix), end
    set(gca, 'Box', 'off','YColor', [36, 126, 214]./256)
    ylabel('µV')
    axis tight
    yl(ind,:)=get(gca,'YLim');

    if ~isempty(eagchan) %plot EAG if channel given
        yyaxis right
        plot(tv,datae(ind,:), 'Color', [1 0 1])
        set(gca, 'YColor', [241, 29, 92]./256)
        ylabel('mV')
        axis tight
        if isempty(LFPchan)
            y2(ind,:)=get(gca,'YLim');
        end
    end %plot EAG if channel given

    if ~isempty(LFPchan) %plot LFP if channel given
        yyaxis right
        plot(tv,datal(ind,:), 'Color', [1 0 0],'LineStyle', '-')
        axis tight
        y2(ind,:)=get(gca,'YLim');
        if isempty(eagchan)
            set(gca, 'YColor', [241, 29, 92]./256)
            ylabel('mV')
        end
    end %plot LFP if channel given
end

%Making legend labels
legendarr(1,1) = {'Spikes'};
if ~isempty(eagchan)
    legendarr(1,end+1) = {'EAG'};
end
if ~isempty(LFPchan)
    legendarr(1,end+1) = {'LFP'};
end
legendarr(1,end+1) = {'Stim'};

%Setting the left axis y limits
m1=min(yl(:,1));
m2=max(yl(:,2));
for ind=1:(ttrials) %for each trial
    subplot(ttrials,1,ind)
    if ~isempty(LFPchan)||~isempty(eagchan)
        yyaxis left
    end
    set(gca,'YLim', [m1 m2])
end %for each trial

%Setting the right axis y limits
if ~isempty(LFPchan)||~isempty(eagchan)
    mm1=min(y2(:,1));
    mm2=max(y2(:,2));
    if abs(mm1)>abs(mm2) %More space below 0
        mm2=mm1*m2/m1; %scale upper limit
    elseif abs(mm1)<abs(mm2) %More space above 0
        mm1=mm2*m1/m2; %scale lower limit 
    end
    
    for ind=1:(ttrials) %for each trial
        subplot(ttrials,1,ind)
        yyaxis right
        set(gca,'YLim', [mm1 mm2]) %set ylims (0 should match left axis)
    end %for each trial
end

%Plotting the stimulus
for ind=1:(ttrials) %for each trial
    clear xx1 xx2 xx3
     subplot(ttrials,1,ind)
    xx1=find(datas(ind,:)>2); %simple threshold to find positive stimulus values larger than 2 volts
    xx2=find(diff(xx1)>1); %find breaks in thresheld stimulus greater than 1 sample point
    xx3=sort([xx1(1) xx1(xx2) xx1(xx2+1) xx1(end)]);
    if ~isempty(LFPchan)||~isempty(eagchan)
        yyaxis right
        plot(tv(reshape(xx3,2,length(xx3)/2)')', ones(2,1)*mm1, 'k-', 'LineWidth', 8)
    else
        plot(tv(reshape(xx3,2,length(xx3)/2)')', ones(2,1)*m1, 'k-', 'LineWidth', 8)        
    end
end %for each trial

%Adding labels
xlabel('time (s)')
subplot(ttrials,1,1)
legend(legendarr, 'Location', 'NorthEast')



