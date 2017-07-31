function lfpvseag(prefix, nlocs, LFPloc, ntrials, stimchan, eagchan, fs, LFPchan,bdndx)

% plotresp(prefix, ntrials, bdndx, respchan, stimchan, eagchan, fs, LFPchan)
%
% Function to plot LFP vs EAG
% Inputs:
% prefix-
% ntrials-
% LFPloc- LFP electrode location in segments
% stimchan-
% eagchan-
% fs-
% LFPchan-

% July 21st 2017, Bk

if nargin<1||isempty(prefix)
    prefix=uigetfile('*.*', 'Choose Prefix File');
    prefix=prefix(1:end-7);
end
if nargin<4||isempty(ntrials), ntrials=5; end
if nargin<5||isempty(stimchan), stimchan=2; end
if nargin<6||isempty(eagchan), eagchan=3; end
if nargin<7||isempty(fs), fs=1e4; end
if nargin<8||isempty(LFPchan), LFPchan=4; end
if nargin<9||isempty(bdndx), bdndx=[]; end
datate = zeros(1,1e5);
tv=(1:length(datate))/fs;
datatl = zeros(1,1e5);
rows =ceil((nlocs)/3);
yl=zeros(nlocs,2);
legendtot = zeros(1,nlocs);
textx = zeros(1,nlocs);
texty = zeros(1,nlocs);
LFP = 1;
EAG = 2;
EAGvLFP = 3;
figure(LFP)
figure(EAG)
figure(EAGvLFP)
for ind=1:nlocs
    prefixnum = [prefix num2str(ind)];
    datae=-parseOneChannel('.',prefixnum,ntrials,bdndx,eagchan)*10000/pow2(16)/500;
    datal=-parseOneChannel('.',prefixnum,ntrials,bdndx,LFPchan)*10000/pow2(16)/500;
    for k = 1:ntrials
        datate =datate+ datae(k,:);
        datatl =datatl+ datal(k,:);
        %remove offset
        datate = datate - sum(datate(1:500))/500;
        datatl = datatl - sum(datatl(1:500))/500;
    end
    figure(EAGvLFP)
    subplot(rows,3,ind)
    hold all
    plot(tv,datate)
    legendarr(1,1) = {'EAG'};
    plot(tv,datatl)
    legendarr(1,2) = {'LFP'};
    ylabel('Response(mV)')
    xlabel('Time(s)')
    if ind-LFPloc<0, loc = 'Distal segments away';
    elseif ind - LFPloc == 0, loc = 'Same segment';
    elseif ind - LFPloc > 0, loc = 'Proxmial segments away'; end
    title([num2str(-ind + LFPloc) ' ' loc])
    yl(ind,:)=get(gca,'YLim');
    legend(legendarr)
    
    figure(LFP)
    hold all
    plot(tv,datatl,'LineWidth', 1)
    legendtot(ind) = -ind + LFPloc;
    
    figure(EAG)
    hold all
    plot(tv,datate,'LineWidth', 2)
    if length(find(datate == max(datate))) > 1,...
            textx(ind) = sum(find(datate == max(datate)))/length(find(datate == max(datate)));
    else
        textx(ind) = find(datate == max(datate));
    end
    texty(ind) = max(datate);
    datatl = 0;
    datate = 0;
end

figure(LFP)
legend(num2str(legendtot'))
title('All LFPs')
ylabel('Response(mV)')
xlabel('Time(s)')

figure(EAG)
legend(num2str(legendtot'))
title('All EAGs')
text(textx/fs,texty+.1,num2str(legendtot'),'FontSize',14,'FontWeight','bold')
ylabel('Response(mV)')
xlabel('Time(s)')

% for ind = 1:nlocs
%     hold all
%
%     annotation('textbox',[textx(ind)/length(tv) textx(ind)/length(tv)+.01...
%         texty(ind)/max(texty) texty(ind)/max(texty)+.01],...
%         'String',num2str(max(legendtot(ind))),'FitBoxToText','on')
% end


%  yzoom(gcf,min(yl(:,1)),max(yl(:,2)))
datats = zeros(1,1e5);
figure(EAGvLFP)
for ind=1:(nlocs)
    clear xx1 xx2 xx3
    prefixnum = [prefix num2str(ind)];
    datas =parseOneChannel('.',prefixnum,ntrials,bdndx,stimchan)*10/pow2(16);
    subplot(rows,3,ind)
    for k = 1:ntrials
        datats = datats+ datas(k,:);
    end
    xx1=find((datats/5)>2);
    xx2=find(diff(xx1)>1);
    xx3=sort([xx1(1) xx1(xx2) xx1(xx2+1) xx1(end)]);
    plot(tv(reshape(xx3,2,length(xx3)/2)')', ones(2,1)*min(yl(:,1)), 'k', 'LineWidth', 8)
    datats = 0;
end
axis tight

%EAG segment vs EAG Peak
figure();
hold all
plot(legendtot,texty,'b*')
plot([0 0],[min(texty) max(texty)],'--','Color',[0.7 0.7 0.7])