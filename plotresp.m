function plotresp(prefix, ntrials, bdndx, respchan, stimchan, eagchan, fs, LFPchan)

% plotresp(prefix, ntrials, bdndx, respchan, stimchan, eagchan, fs, LFPchan)
%
% Function to plot all response trials for physiology data in separate
% panels in a single figure
% Inputs:
% prefix-
% ntrials-
% bdndx-
% respchan-
% stimchan-
% eagchan-
% fs-
% LFPchan-

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
if nargin<2||isempty(ntrials), ntrials=5; end
if nargin<3||isempty(bdndx), bdndx=[]; end
if nargin<4||isempty(respchan), respchan=1; end
if nargin<5||isempty(stimchan), stimchan=2; end
if nargin<7||isempty(fs), fs=1e4; end
gain=5000;
ttrials=ntrials-length(bdndx);

%Spiking channel
data=parseOneChannel('.',prefix,ntrials,bdndx,respchan)*10000000/pow2(16)/gain;
%Stim channel
datas=parseOneChannel('.',prefix,ntrials,bdndx,stimchan)*10/pow2(16);
%EAG channel
if exist('eagchan', 'var')
    if ~isempty(eagchan)
        datae=-parseOneChannel('.',prefix,ntrials,bdndx,eagchan)*10000/pow2(16)/500;
        for ind=1:ttrials
            datae(ind,:)=datae(ind,:)-mode(datae(ind,:));
        end
    end
end
%LFP channel , gain at 500 (Last number)
if exist('LFPchan', 'var')
    if ~isempty(LFPchan)
        datal=-parseOneChannel('.',prefix,ntrials,bdndx,LFPchan)*10000/pow2(16)/500;
        for ind=1:ttrials
            datal(ind,:)=datal(ind,:)-mode(datal(ind,:));
        end
    end
end


tv=(1:length(data))/fs;
figure
set(gcf,'Pos', [450 90 560 900])
yl=zeros(ttrials,2);
for ind=1:(ttrials)
    subplot(ttrials,1,ind)
    plot(tv,data(ind,:), 'color', [36, 126, 214]./256)
    hold on
    if ind==1, title(prefix), end
    if exist('eagchan', 'var')
        if ~isempty(eagchan)
            yyaxis right
            plot(tv,datae(ind,:), 'Color', [1 0 1])
            legendarr(1,2) = {'EAG'};
        end
    end
    if exist('LFPchan', 'var')
        if ~isempty(LFPchan)
            plot(tv,datal(ind,:), 'Color', [1 0 0],'LineStyle', '-')
            legendarr(1,3) = {'LFP'};
        end
    end
    yl(ind,:)=get(gca,'YLim');
    yyaxis left
    set(gca, 'Box', 'off','YColor', [36, 126, 214]./256)
    legendarr(1,1) = {'Spikes'};
    ylabel('µV')
    yyaxis right
    set(gca, 'YColor', [241, 29, 92]./256)
    ylabel('mV')
    
end
%  yzoom(gcf,min(yl(:,1)),max(yl(:,2)))
% subplot(ttrials+1,1,ttrials+1)
% plot(tv,mean(datas)), axis tight
% ylabel('stim')
subplot(5,1,1)
legend(legendarr, 'Location', 'NorthEast')
for ind=1:(ttrials)
    clear xx1 xx2 xx3
    subplot(ttrials,1,ind)
    xx1=find(datas(ind,:)>2);
    xx2=find(diff(xx1)>1);
    xx3=sort([xx1(1) xx1(xx2) xx1(xx2+1) xx1(end)]);
    plot(tv(reshape(xx3,2,length(xx3)/2)')', ones(2,1)*min(yl(:,1)), 'k', 'LineWidth', 8)
end

axis tight
xlabel('time (s)')



