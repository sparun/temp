% wm_ecubeProperties -> The function has all the ecube properties values, as given by user, WM.
% 
% Required Inputs
%       None
% 
% Outputs
%       ecube: is a struct with three fields: [specs, digital, analog]
%           touchscreen: struct with following fields:
%               modelname               : actual model name of the monkey-side monitor
%               brightness              : brightness percentage in elo monitor on monkey side
%               contrast                : contrast percentage in elo monitor on monkey side
%               refreshrate             : refresh rate of elo monitor on monkey side, in Hz
%               maxtouches              : max number of touches that can be registered by the PCAP monitor.
%           specs: struct with following fields:
%               netcamFrameRate         : hardcoded in recording setup.
%               samplingRate            : hardcoded analog & digital data sampling rate for ecube (in sps).
%               nAnalogChannels         : number of recorded analog channels
%               analogVoltPerBit        : Given by wm for bit to voltage conversion
%               expectedRecordDuration  : default is 600 (10 minutes chunks of recording)
%           digital: struct with following fields:
%               netcamSync              : digital channel id for Netcam pulse 
%               HSWsync                 : digital channel id for HSW sync signal to ecube box
%               strobe                  : digital channel id for strobe input hardcoded in setup
%               eventcodes              : digital channel ids for sending eventcodes from ML to ecube box, hardcoded in setup
%           analog: Struct with following fields
%               eyeX                    : analog channel id for the eyeX data
%               eyeY                    : analog channel id for eyeY data
%               pupilArea               : analog channel id for pupilArea coming from serial data
%               photodiode              : analog channel id for photodiode data
%               MLstrobe                : mlstrobe split into both analog and digital channels
% 
% Version History:
%    Date               Authors             Notes
%   08-Nov-2021         Georgin, Thomas     Initial implementation
%   31-Oct-2022         Jhilik, Surbhi      Added documentation
%   07-Jan-2023         Arun, Shubho        Minor cleanup
%   25-Jan-2023         Shubho              Updated with elo monitor specs
% ========================================================================================

function ecube = wm_ecubeProperties

% define monitor specs
ecube.touchscreen.modelname         = 'ELO 1593L TouchPro PCAP E331799, 15.6inch openframe'; 
ecube.touchscreen.brightness        = 100; % percentage
ecube.touchscreen.contrast          = 50;  % percentage
ecube.touchscreen.refreshrate       = 60;  % Hz
ecube.touchscreen.maxtouches        = 10;  % number of maximum touches registerable

% define hardware specs
ecube.specs.netcamFrameRate         = 30;
ecube.specs.samplingRate            = 25000;
ecube.specs.nAnalogChannels         = []; % will be updated by wm_readAnalogData
ecube.specs.analogVoltPerBit        = 3.0517578125e-4;
ecube.specs.expectedRecordDuration  = 600; % in seconds

% defining digital inputs into ecube box
ecube.digital.netcamSync            = 1;
ecube.digital.HSWsync               = 2; 
ecube.digital.strobe                = 3;
ecube.digital.eventcodes            = 41:64;

% definining analog inputs into ecube box
ecube.analog.eyeX                   = 1;
ecube.analog.eyeY                   = 2;
ecube.analog.pupilArea              = 3; 
ecube.analog.photodiode             = 4;
ecube.analog.MLstrobe               = 5;

% fields for monitor specs
n=0;fields={};
n=n+1;fields{n,1}= 'modelname               = touchscreen model name';
n=n+1;fields{n,1}= 'brightness              = brightness setting used for recordings';
n=n+1;fields{n,1}= 'contrast                = contrast setting used for recordings';
n=n+1;fields{n,1}= 'refreshrate             = monitor refresh rate in Hz';
n=n+1;fields{n,1}= 'maxtouches              = max number of touches registerable';
ecube.touchscreen.fields = fields; 

% Fields for specs
n=0;fields={};
n=n+1;fields{n,1}= 'netcamFrameRate         = frame rate of netcam recording';
n=n+1;fields{n,1}= 'samplingRate            = ecube sampling frequency for both digital & analog data';
n=n+1;fields{n,1}= 'nAnalogChannels         = number of analog channels recorded in ecube';
n=n+1;fields{n,1}= 'analogVoltPerBit        = volt value per bit for analog data as provided in settings.xml file';
n=n+1;fields{n,1}= 'expectedRecordDuration  = set record duration chunk after which a new digital / analog file will be created in continuity';
ecube.specs.fields  = fields;

% Fields for Digital bits
n=0;fields={};
n=n+1;fields{n,1}= 'netcamSync      = channel number for netcam sync signal in ecube digital bit section';
n=n+1;fields{n,1}= 'HSWsync         = channel number for hsw sync in ecube digital bit section';
n=n+1;fields{n,1}= 'strobe          = channel number for ml-strobe in ecube digital bit section';
n=n+1;fields{n,1}= 'eventcodes      = channel numbers for eventcodes in ecube digital bit section';
ecube.digital.fields = fields;

% Fields for Analog Data
n=0;fields={};
n=n+1;fields{n,1}= 'eyeX        = channel number to collect eye-X data from ISCAN in ecube analog bit section';
n=n+1;fields{n,1}= 'eyeY        = channel number to collect eye-Y data from ISCAN in ecube analog bit section';
n=n+1;fields{n,1}= 'pupilArea   = channel number to collect pupilarea data from ISCAN in ecube analog bit section';
n=n+1;fields{n,1}= 'photodiode  = channel number to collect photodiode data in ecube analog bit section';
n=n+1;fields{n,1}= 'MLstrobe    = channel number for ml-strobe in ecube analog bit section';
ecube.analog.fields  = fields;

end