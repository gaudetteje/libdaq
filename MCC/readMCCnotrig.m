clc
clear

% clean up any old sessions
if exist('ai','var')
    delete(ai)
end

% user defined parameters
fs = 50e3;      % max fs is 50kHz/ch or 100kSps total
T = 1;          % time period to record
r = 1;          % input voltage range

% derive constants
L = ceil(T*fs);     % convert time to number of samples


%%% setup hardware
ai=analoginput('mcc');
ch=addchannel(ai,0,{'x'});


%%% setup DAQ sampling
ai.SampleRate = fs;
ai.SamplesPerTrigger = L;
ai.TriggerType = 'Immediate';


%%% setup DAQ channel
ai.Channel.InputRange = [-r r];
ai.Channel.SensorRange = [-r r];
ai.Channel.UnitsRange = [-r r];
ai.Channel.Units = ('Volts');


% setup data directory and make it the cwd
dname = datestr(now,'yyyy-mm-dd');
dname = [dname '_' input(['Enter data directory name:  ' dname '_'],'s')];
if ~exist(dname,'dir')
    mkdir(dname)
else
    warning('Directory already exists - data will be appended')
end


% begin data collection
fprintf('Beginning data acquisition...\n')
start(ai);
wait(ai,T+2);


% retrieve stored time series data
ts.fs = ai.SampleRate;
[ts.data,ts.time] = getdata(ai);

% plot data
plotDAQdata(ts)

% save data to file
matname = [datestr(now,'yyyy-mm-dd HH_MM_SS') '.mat'];
save(fullfile(dname,matname),'ts')
 
% cleanup
fprintf('Cleaning up\n')
delete(ai);
clear ai ch
