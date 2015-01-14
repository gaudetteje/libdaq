function fd = plotDAQdata(ts,fband)
% PLOTDAQDATA plots the time series, power spectral density, and
% spectrogram of time series data
%
% plotDAQdata(ts) plots time series and frequency spectrum with the mean
%   DC level subtracted
% plotDAQdata(ts,fc) applies a forward-backward filter to the data before
%   plotting and computing the frequency spectrum.  'fc' is either a
%   2-element array or a scalar.  When fc = [fl fh], a bandpass filter is
%   used with cutoff frequencies of fl and fh.  If fc is a number less
%   than 10% of the sampling rate, a high-pass filter is used with a
%   cutoff frequency of fc Hz.  Otherwise, a low-pass filter is used.
% fd = plotDAQdata(...) also returns the frequency analysis data
%
% Note:  The forward-backward filter is used to cancel out phase shifts
% caused by the filtering.  Therefore, an Nth order magnitude response will
% be applied as a 2*Nth order filter with zero-phase shift and no group
% delay.

yRange = 100;
cRange = 40;

% remove low frequency noise component
if nargin > 1
    if numel(fband) > 1
        % design 2nd order max-flat bandpass filter
        [b,a] = butter(2,fband.*(2/ts.fs));
    else if (fband < 0.1*ts.fs)
            % design 2nd order max-flat highpass filter
            [b,a] = butter(2,fband.*(2/ts.fs),'high');
        else
            % design 2nd order max-flat lowpass filter
            [b,a] = butter(2,fband.*(2/ts.fs));
        end
    end
    ts.data = filtfilt(b,a,ts.data);
end
ts.data = ts.data - mean(ts.data);

% estimate frequency spectrum
fd = calc_spectrum(ts.data,ts.fs);
fd = convert_spectrum(fd,'Vrms/rtHz');

% plot data
figure(gcf)

subplot(4,1,1)
plot(ts.time,ts.data(:,1))
xlabel('Time (sec)')
ylabel('Amplitude (V)')
grid on

subplot(4,1,2)
plot(fd.freq*1e-3,fd.magdb)
ylabel(sprintf('Amplitude (dB%s)',fd.units))
xlabel('Freqency (kHz)')
yMax = max(get(gca,'yLim'));
set(gca,'ylim',[yMax-yRange yMax])
grid on

subplot(4,1,3:4)
spectrogram(ts.data,256,200,512,ts.fs*1e-3,'yaxis')
xlabel('Time (ms)')
ylabel('Frequency (kHz)')
colormap(jet)
cMax = max(get(gca,'cLim'));
set(gca,'clim',[cMax-cRange cMax])

colorbar
% play sound recorded
%sound(ts.data(:,1),ts.fs)
