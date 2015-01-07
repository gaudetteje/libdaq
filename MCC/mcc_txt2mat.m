% converts MCC Oscope txt data to MAT files
close all
clear
clc

cwd = '.';

files = findfiles(cwd,'\.txt$');
%files = {uigetfile('.txt','Locate TXT files')};

for n=1:numel(files)
    fid = fopen(files{n});
    
    res = textscan(fid,'%s%f',1,'Delimiter',':','Headerlines',3);
    fs = res{2};
    
    fseek(fid,0,-1);
    res = textscan(fid,'%f%s%f%f','Delimiter',',','Headerlines',7);
    fclose(fid);
    
    t = res{1}./fs;
    x1 = res{3};
    %x2 = res{4};
    
    x1 = x1-mean(x1);
    
    figure(1)
    set(gcf,'color','w')
    subplot(3,1,1)
    plot(t*1e3,x1)
    grid on
    title(files{n},'interpreter','none')
    xlabel('Time (ms)')
    
    subplot(3,1,2:3)
    nfft = 128;
    spectrogram(x1,blackman7(32),30,nfft,fs*1e-3,'yaxis')  %[zeros(nfft,1); x1; zeros(nfft,1)]
    ylabel('Frequency (kHz)')
    xlabel('Time (ms)')
    cLim = get(gca,'cLim');
    set(gca,'cLim',[cLim(2)-60 cLim(2)]);
    colorbar('location','southoutside')
    pause
end
