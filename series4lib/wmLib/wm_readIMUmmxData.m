%
% wm_readIMUmmxData -> This read .bin IMU data and gives the readings from accelerometer (ch 1:3),
% magnetometer (ch 4:6), gyroscope (ch 7:10)
%
% Required Inputs:
%       fullFileName  : give the path to the .bin file being read
%       nchans        : number of total channels
%       sensitivity   : it changes the gain factor of the sensors
%
% Outputs:
%       acc   : data from 3 channels of accelerometer (x,y,z)
%       gyr   : data from 3 channels of gyroscope (x,y,z axes of rotation)
%       mag   : data from 4 channels of magnetometer
% 
% Version History:
%    Date               Authors             Notes
%    Unknown            SP Arun             Created the first version
%    16-Nov-2022        Jhilik, Surbhi      Converted into function
%
% ========================================================================================


function IMUdata = wm_readIMUmmxData(neuralFilePath,sensitivity)
imuFile = dir([neuralFilePath '\*_mmx_imu_*.bin']);
if(length(imuFile)>1), error('FAILURE! Multiple IMU files found - please check!'); end 

acc=[]; gyr = []; mag = []; timu = []; imu = []; timu = []; nchannels = 10; IMUdata = []; 
if(~isempty(imuFile))
    fid = fopen(imuFile,'r');
    t = fread(fid,1,'uint64=>uint64'); % read timestamp from start of file
    timu = cat(1,timu,t);
    d = fread(fid,[nchannels,inf],'int16=>single');
    imu = cat(nchannels,imu,d);
    fclose(fid);
    acc = imu(1:3,:); % accelerometer data
    gyr = imu(4:6,:); % gyroscope data
    mag = imu(7:10,:); % magnetometer data

    % scale sensitivity based on gain set during recording (scaling factors are given by WM) 
    switch sensitivity 
        case 'low' 
            acc = acc * 16 / 32768;     
            gyr = gyr * 2000 / 32768;    
        case 'medium'
            acc = acc * 8 / 32768;
            gyr = gyr * 1000 / 32768;
        case 'high'
            acc = acc * 4 / 32768;
            gyr = gyr * 500 / 32768;
        otherwise
            warning('IMU sensitivity not set as low/medium/high - returning unscaled values');
    end
    IMUdata.acc = acc; IMUdata.gyr = gyr; IMUdata.mag = mag; IMUdata.timu = timu; 
end

end