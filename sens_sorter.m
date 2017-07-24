function sens_sorter(pfs, spikes, clustndx)

%pfs - [{odorant} {odorant} ... {odorantmuilti}]
%spikes - template 
%clustndx - interested clusters in the template

opts_1.bdndx = [];
opts_1.ntrials = 5;
opts_1.xval = 'auto';

for ind = 1:length(pfs)
    
    opts_1.prefix = pfs{ind}
    spikes_out = pouzatclass1(spikes,opts_1);
    spikes_out1 = removeoutliers_aut(spikes_out,23,[],'euclidean');
    spikes_out2 = removeoutliers_aut(spikes_out1,.99,[],'mahalanobis');
    if length(spikes_out2.waveforms_clust)> 1 
    [fpos, fneg] = toterr_rt(spikes_out2)
    if any(fpos(clustndx)>5) | any(fneg(clustndx)>5), break, end
    save(strcat(opts_1.prefix,'_class', '_err'), 'fpos', 'fneg', 'clustndx')
    end
    save(strcat(opts_1.prefix,'_class'), 'spikes_out2')
    sortdata2spikes(spikes_out2,opts_1.prefix, clustndx,2,4,3,[]);
    
    clearvars -EXCEPT opts_1 spikes pfs clustndx
end
    