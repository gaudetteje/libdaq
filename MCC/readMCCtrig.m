function readMCCtrig(varargin)
% READMCCTRIG  acquire data from Measurement Computing DAQ
%
% readMCCtrig(0) uses immediate data acquisition
% readMCCtrig(1) acquires a single acquisition using the software trigger
% readMCCtrig(N) acquires N acquisitions using the software trigger

global dname ai

% clean up any old sessions
if exist('ai','var')
    delete(ai)
end

% user defined parameters
fs = 175e3;%45e3; %      % max fs is 50kHz/ch or 100kSps total
T = 3;          % time period to record
r = 1;          % input voltage range

% default parameters
N = 0;          % number of trigger events to store
A = 0.01;        % trigger threshold

switch nargin
    case 0
    case 1
        N = varargin{1};
    case 2
        N = varargin{1};
        A = varargin{2};
    otherwise
        error('Incorrect number of parameters entered')
end

% derive constants
L = ceil(T*fs);     % convert time to number of samples


%%% setup hardware
ai=analoginput('mcc');
ch=addchannel(ai,0,{'x'});

%%% setup DAQ sampling
ai.SampleRate = fs;
ai.SamplesPerTrigger = L;

%%% setup DAQ channel
ai.Channel.InputRange = [-r r];
ai.Channel.SensorRange = [-r r];
ai.Channel.UnitsRange = [-r r];
ai.Channel.Units = ('Volts');

if N > 0

    % setup DAQ trigger properties
    ai.TriggerChannel = ch(1);
    ai.TriggerType = 'Software';
    ai.TriggerCondition = 'Rising';

    ai.TriggerConditionValue = A;       % trigger level
    ai.TriggerDelay = -0.01;            % pretrigger delay
    ai.TriggerRepeat = N-1;             % repeat triggers (N-1)
else
    ai.TriggerType = 'Immediate';
end

%%% point DAQ to callback function
ai.SamplesAcquiredFcnCount = L; 
ai.SamplesAcquiredFcn = {@mcc_trigger_callback};

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

if N > 0
    % wait for user response
    fprintf('\nPress any key to stop data acquisition...\n')
    pause
else
    wait(ai,T+2);
end

% wait for DAQ completion
while strcmp(ai.Running,'On')
    pause(0.25)
end

% cleanup
fprintf('Cleaning up\n')
delete(ai);
clear ai ch
