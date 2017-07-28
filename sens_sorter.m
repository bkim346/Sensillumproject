function sens_sorter(pfs, spikes, clustndx, bdndx)

%pfs - [{odorant} {odorant} ... {odorantmuilti}]
%spikes - template
%clustndx - interested clusters in the template

opts_1.bdndx = [];
opts_1.ntrials = 5;
opts_1.xval = 'auto';

for ind = 1:length(pfs)
    
    opts_1.prefix = pfs{ind}
    spikes_out = pouzatclass1(spikes,opts_1);
    spikes_out1 = removeoutliers_aut(spikes_out,24,[],'euclidean');
    spikes_out2 = removeoutliers_aut(spikes_out1,.995,[],'mahalanobis');
    save(strcat(opts_1.prefix,'_class'), 'spikes_out2', 'spikes_out', 'spikes_out1')
    if length(clustndx)> 1
        [fpos, fneg] = toterr_rt(spikes_out2)
        if any(fpos(clustndx)>5) | any(fneg(clustndx)>5), break, end
        save(strcat(opts_1.prefix,'_class', '_err'), 'fpos', 'fneg', 'clustndx')
    end
    sortdata2spikes(spikes_out2,opts_1.prefix, clustndx,2,4,3,[]);
    
    clearvars -EXCEPT opts_1 spikes pfs clustndx
end
