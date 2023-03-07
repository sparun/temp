
%function PO=sd_images_mb(PI)
%   FORMAT PO=sd_images(PI,sdoptions)
%   PI      - matrix with rows=input filenames (if empty ([]), filenames can be selected in
%             GUI window)
%   PO      - output filenames
%
%   this function calculates the standard deviation, mean, relative
%   standard deviation (to mean) and temporal SNR image.
%   of the images in PI and saves the result in 3 images (average,sd.img,rsd.img, snr.img)
%   the image is saved in the directory of the first image selected
%   ________________________________________________
% % SPM2 dependent (SPM2 has to be in matlab path)!
% %W% Bas Neggers 2004 %E%

maxSNR=100000; % maximum SNR value (above will be clipped to prevent scaling induced flattening in snr.nii)
if ispc
    slashstr = '\';
else
    slashstr = '/';
end

sdoptions = [];
if isempty(PI),
    PI=spm_select(Inf, 'image', 'Select images to calculate sd');
end
if isempty(sdoptions)
    sdoptions.meanonly=0;
    sdoptions.altdir='';
    sdoptions.binaryon=0;
end
if ~isfield(sdoptions,'altdir')
    sdoptions.altdir='';
end
if ~isfield(sdoptions,'meanonly')
    sdoptions.meanonly=0;
end
if ~isfield(sdoptions,'binaryon') %average will be computed from binarized images (that is, 0 when 0, 1 otherwise)
    sdoptions.binaryon=0;
end
PO='';
[pth,nam,ext,vol] = spm_fileparts( deblank (PI(1,:)));
if findstr(nam,'_'), nam = nam(1:findstr(nam,'_')-1); end
if size(PI,1) == 1
    PI = fullfile(pth,[nam, ext]); %remove volume is 'img.nii,1' -> 'img.nii' need to do this for 4D for some reason :/
end
VIs          = spm_vol(PI);
[Data]=spm_read_vols(VIs(1));
N=size(VIs,1); %PI,1);

Average_Data=zeros(size(Data(:,:,:,1)));
SD_Data2=zeros(size(Data(:,:,:,1)));

for i=1:N,
    Data=spm_read_vols(VIs(i));
    Datad=Data;
    if sdoptions.binaryon
        Data(Datad>=sdoptions.binarythr)=1; %binarize
        Data(Datad<sdoptions.binarythr)=0; %binarize
    end
    %disp(i);
    Average_Data=Average_Data+Data/N;
end
for i=1:N,
    Data=spm_read_vols(VIs(i));
    SD_Data2=SD_Data2+(Average_Data-Data).^2;
end
SD_Data=sqrt(SD_Data2/(N-1));
SD_Data_Rel=SD_Data./Average_Data;
SD_Data_SNR=Average_Data./SD_Data;

VO=VIs(1);
if ~isempty(sdoptions.altdir)
    resdir=sdoptions.altdir;
else
    isl=strfind(VO.fname,slashstr); %findstr(VO.fname,slashstr);
    resdir=VO.fname(1:isl(end));
end

VO.fname    = [niifolder subjectid '_map_01_mean.nii'];
VO=rmfield(VO,'pinfo'); %rescales data
spm_write_vol(VO,Average_Data);
PO{1}=VO.fname;

if ~sdoptions.meanonly
    VO.fname    = [niifolder subjectid '_map_02_sd.nii'];
    spm_write_vol(VO,SD_Data);
    PO{2}=VO.fname;
    % VO.fname    = [niifolder subjectid '_map_01_rsd.nii'];
    % spm_write_vol(VO,SD_Data_Rel);
    % PO{3}=VO.fname;
    VO.fname    = [niifolder subjectid '_map_03_snr.nii'];
    SD_Data_SNR_clipped=SD_Data_SNR;
    SD_Data_SNR(SD_Data_SNR>maxSNR)=NaN;
    spm_write_vol(VO,SD_Data_SNR); %_clipped);
    PO{4}=VO.fname;
end

% %  OLD CODE
% %   FORMAT PO=sd_images(PI)
% %   PI      - matrix with rows=input filenames (if empty ([]), filenames can be selected in
% %             GUI window)
% %   PO      - output filenames
% %
% %   this function calculates the standard deviation, mean, relative
% %   standard deviation (to mean) and temporal SNR image.
% %   of the images in PI and saves the result in 3 images (average,sd.img,rsd.img, snr.img)
% %   the image is saved in the directory of the first image selected
% %   ________________________________________________
% % % SPM2 dependent (SPM2 has to be in matlab path)!
% % %W% Bas Neggers 2004 %E%
%
% maxSNR=100000; % maximum SNR value (above will be clipped to prevent scaling induced flattening in snr.nii)
% if ispc
%     slashstr='\';
% else
%     slashstr='/';
% end
% if isempty(PI),
%     PI=spm_select(Inf, '*', 'Select images to calculate sd');
% end
% PO='';
% VIs          = spm_vol(PI);
% Data=spm_read_vols(VIs(1));
% Average_Data=zeros(size(Data));
% SD_Data2=zeros(size(Data));
% N=size(PI,1);
% for i=1:N,
%     Data=spm_read_vols(VIs(i));
%     %disp(i);
%     Average_Data=Average_Data+Data/N;
% end
% for i=1:N,
%     Data=spm_read_vols(VIs(i));
%     SD_Data2=SD_Data2+(Average_Data-Data).^2;
% end
% SD_Data=sqrt(SD_Data2/(N-1));
% SD_Data_Rel=SD_Data./Average_Data;
% SD_Data_SNR=Average_Data./SD_Data;
%
% VO=VIs(1);
% isl=strfind(VO.fname,slashstr); %findstr(VO.fname,slashstr);
% VO.fname    = [VO.fname(1:isl(end)),'average.nii'];
% spm_write_vol(VO,Average_Data);
% PO{1}=VO.fname;
% VO.fname    = [VO.fname(1:isl(end)),'sd.nii'];
% spm_write_vol(VO,SD_Data);
% PO{2}=VO.fname;
% VO.fname    = [VO.fname(1:isl(end)),'rsd.nii'];
% spm_write_vol(VO,SD_Data_Rel);
% PO{3}=VO.fname;
% VO.fname    = [VO.fname(1:isl(end)),'snr.nii'];
% SD_Data_SNR_clipped=SD_Data_SNR;
% SD_Data_SNR_clipped(SD_Data_SNR_clipped>maxSNR)=NaN;
% spm_write_vol(VO,SD_Data_SNR); %_clipped);
% PO{4}=VO.fname;


