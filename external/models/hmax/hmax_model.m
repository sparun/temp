%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 	  MODULE: main.m
%%
%%      FUNCTION: some code to show how calcCSSITC2new.m is called and how
%%                variables are set up (together with init_HMAX.m)
%%
%%   DESCRIPTION: this code demonstrates how to initialize the
%%                parameters and call calcCSSITC2new for an
%%                image. To run this from a Matlab prompt, simply
%%                type '>>main'. The output is a vector of C2
%%                responses in the variable 'c2Resp'.
%%                Look at the file init_HMAX.m to see how to set
%%                the parameters.
%%
%% last modified: 08/25/2004
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% which filters for the simple cells do we want to use? Options are
% 'gaussian1st': first derivative of a Gaussian
% 'gaussian': second derivative of a Gaussian
% 'gabor': Gabor filters (more realistic)

allclear;

load L2_view;
imgs = L2_str.actual_items; nimgs = length(imgs);
% Put the images on a smaller frame but retaining the size
for i = 1:nimgs;
    T1 = imgs{i}; T1 = RemoveZeros(T1);
    if i~= 40; T1 = pad(T1,200); newimgs{i} = T1; else; T1 = pad(T1,400); newimgs{i} = T1; end;
end


%%
for filtertype = 3
    if filtertype == 1; whichFilter = 'gaussian'; else if filtertype == 2; whichFilter = 'gaussian1st'; else; whichFilter = 'gabor'; end; end;
    fprintf('Running HMAX model for for FilterType %s...\n',whichFilter);
    for imgid = 1:nimgs;
        
        % initialize the parameters (look at the source code of init_HMAX.m
        % to see them)
        init_HMAX;
        % load the image
        stim = newimgs{imgid}; stim=double(stim);
        % ...and now calculate the C2 response by calling calcCSSITC2new:
        c2hmax(:,imgid)=calcCSSITC2new(stim,0)';
    end
    data(filtertype,:,:) = c2Resp;
end

save hmaxdata

break 
%% Code to create hmaxdata
allclear; 
load hmaxdata
% Gaussian1st derivative filter
data2 = squeeze(data(1,:,:));
c2_gaussian1st = pdist(data2','cityblock');
% with Gaussian filter
data2 = squeeze(data(2,:,:));
c2_gaussian = pdist(data2','cityblock');
% with gabor filter
load c2gabor
data2 = c2gabor;
c2_gabor = pdist(data2','cityblock');

hmaxdata(1,:) = c2_gaussian1st;
hmaxdata(2,:) = c2_gaussian;
hmaxdata(3,:) = c2_gabor;
