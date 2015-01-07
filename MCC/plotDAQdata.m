function plotDAQdata(ts)

% remove low frequency noise component
%fc = 10;        % highpass cutoff frequency (Hz)
%[b,a] = butter(2,fc*(2/ts.fs),'high');
%ts.data = filtfilt(b,a,ts.data);
%ts.data = ts.data - mean(ts.data);

% estimate frequency spectrum
fd = calc_spectrum(ts.data,ts.fs);
fd = convert_spectrum(fd,'Vrms/rtHz');

% plot data
figure
subplot(4,1,1)
plot(ts.time,ts.data(:,1))
grid on

subplot(4,1,2)
plot(fd.freq*1e-3,fd.magdb)
ylabel(sprintf('Amplitude (%s)',fd.units))
xlabel('Freqency (kHz)')
set(gca,'ylim',[-120 -50])
grid on

subplot(4,1,3:4)
spectrogram(ts.data,256,200,512,ts.fs*1e-3,'yaxis')
xlabel('Time (ms)')
ylabel('Frequency (kHz)')
colormap(jet)
set(gca,'clim',[-80 -50])

colorbar
% play sound recorded
%sound(ts.data(:,1),ts.fs)
