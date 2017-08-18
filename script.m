sorted = union(depthf,union(depthe,union(depthd,union(depthc,union(deptha,depthb)))));
texty = zeros(1,length(sorted));
stdevbardt = NaN(6,length(sorted));
stdevbarnum = zeros(1,length(sorted));

%%
%normalize with initial value
textya= textya - textya(1);
textyb= textyb - textyb(1);
textyc= textyc - textyc(1);
textyd= textyd - textyd(1);
textye= textye - textye(1);
textyf= textyf - textyf(1);

%%
%Z-score normalize
textya=(textya- mean(textya))/std(textya);
textyb=(textyb- mean(textyb))/std(textyb);
textyc=(textyc- mean(textyc))/std(textyc);
textyd=(textyd- mean(textyd))/std(textyd);
textye=(textye- mean(textye))/std(textye);
textyf=(textyf- mean(textyf))/std(textyf);


%%
datapoints = zeros(1,length(sorted));
for ind = 1:length(sorted)
    if any(sorted(ind) == deptha)
        texty(ind) = textya(find(sorted(ind) == deptha));
        stdevbardt(1,ind) = textya(find(sorted(ind) == deptha));
        datapoints(ind) = 1;
    end
    
    if any(sorted(ind) == depthb)&& ~isempty(texty(ind))
        texty(ind) = texty(ind) + textyb(find(sorted(ind) == depthb));
        stdevbardt(2,ind) = textyb(find(sorted(ind) == depthb));
        datapoints(ind) = datapoints(ind) + 1;
    elseif any(sorted(ind) == depthb)
        texty(ind) = textyb(find(sorted(ind) == depthb)) ;
        stdevbardt(2,ind) = textyb(find(sorted(ind) == depthb));
    end
    
    if any(sorted(ind) == depthc)&& ~isempty(texty(ind))
        texty(ind) = texty(ind) + textyc(find(sorted(ind) == depthc));
        stdevbardt(3,ind) = textyc(find(sorted(ind) == depthc));
        datapoints(ind) = datapoints(ind) + 1;
    elseif any(sorted(ind) == depthc)
        texty(ind) = textyc(find(sorted(ind) == depthc)) ;
        stdevbardt(3,ind) = textyc(find(sorted(ind) == depthc));
    end
    
    if any(sorted(ind) == depthd)&& ~isempty(texty(ind))
        texty(ind) = texty(ind) + textyd(find(sorted(ind) == depthd));
        stdevbardt(4,ind) = textyd(find(sorted(ind) == depthd));
        datapoints(ind) = datapoints(ind) + 1;
    elseif any(sorted(ind) == depthd)
        texty(ind) = textyd(find(sorted(ind) == depthd)) ;
        stdevbardt(4,ind) = textyd(find(sorted(ind) == depthd));
    end
    
    if any(sorted(ind) == depthe)&& ~isempty(texty(ind))
        texty(ind) = texty(ind) + textye(find(sorted(ind) == depthe));
        stdevbardt(5,ind) = textye(find(sorted(ind) == depthe));
        datapoints(ind) = datapoints(ind) + 1;
    elseif any(sorted(ind) == depthe)
        texty(ind) = textye(find(sorted(ind) == depthe)) ;
        stdevbardt(5,ind) = textye(find(sorted(ind) == depthe));
    end
    
    if any(sorted(ind) == depthf)&& ~isempty(texty(ind))
        texty(ind) = texty(ind) + textyf(find(sorted(ind) == depthf));
        stdevbardt(6,ind) = textyf(find(sorted(ind) == depthf));
        datapoints(ind) = datapoints(ind) + 1;
    elseif any(sorted(ind) == depthf)
        texty(ind) = textyf(find(sorted(ind) == depthf)) ;
        stdevbardt(5,ind) = textyf(find(sorted(ind) == depthf));
    end
end

for ind = 1:length(sorted)
    texty(ind) = texty(ind) / datapoints(ind);
    stdevbarnum(ind) = nanstd(stdevbardt(:,ind))/sqrt(datapoints(ind))*1.98;
end
close all
errorbar(sorted,texty,stdevbarnum,'.','markersize',15)
%plot(sorted,texty)
%ylabel('\Delta EAG peak amplitude(mv)')
ylabel('\Delta Standard deviation of EAG peak amplitude(mv)')
xlabel('Depth (\mum)')
title('Depth into Antenna vs EAG peak amplitude')
hold on
[b,bint,r,rint,stats]=regress(texty', [sorted; ones(1, length(sorted))]')
plot(sorted, [sorted; ones(1, length(sorted))]'*b,'r--', 'LineWidth', 2)