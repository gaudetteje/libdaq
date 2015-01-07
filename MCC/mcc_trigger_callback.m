function mcc_trigger_callback(ai,res)
global dname

fprintf('Acquired!\n')

% retrieve stored time series data
ts.fs = ai.SampleRate;
[ts.data,ts.time] = getdata(ai);

ai.SamplesAcquiredFcn = {@myFn};
%ai.flushdata

% show results
fprintf('Plotting results...\n')
close all
plotDAQdata(ts)

% figure(1)
% subplot(3,1,1)
% plot(ts.time,ts.data(:,1))
% grid on
% subplot(3,1,2:3)
% spectrogram(ts.data,256,200,256,ts.fs*1e-3,'yaxis')
% xlabel('Time (ms)')
% ylabel('Frequency (kHz)')
% colormap(jet)

% save data to file
matname = [datestr(now,'yyyy-mm-dd HH_MM_SS') '.mat'];
while existfile(matname)
    matname = [matname '_1'];
end
save(fullfile(dname,matname),'ts')
 
