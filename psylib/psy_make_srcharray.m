% psy_make_srcharray returns the search array.
% REQUIRED INPUTS:
% T          - a single target image
% D          - a cell array of distracter images.

% OPTIONAL INPUTS:
% setsize    - [n m nitems];
%              n - number of rows of display items
%              m - number of columns of display items
%              nitems - number of items to be displayed (<= n*m)
%              By default, setsize = [4 4 16];
% boxsize    - [rowscale colscale] in pixels of the imaginary grid box in which the search items are displayed.
%              By default, boxsize will be 1.5 times the longest dimension among T and D.
% targetpos  - position of the target in the array, counting down columns from left-right
%              Example: pos = 5 puts the target at row1, col2 in a 4x4 array.
%              If targetpos is has more than 1 position, a random position
%              will be chosen for the target among the given positions.
%              By default, targetpos will be chosen randomly.
% posjitter  - [rowjitter coljitter] specifies jitter within the imaginary box as a fraction of boxsize
% distpdf    - probability of appearance of each kind of distracter
%              default: uniform distribution
%              e.g. distpdf = [0.5 0.3 0.2] ensures 50% of D{1}, 30% of D{2} and 20% of D{3}.
%              Note that distpdf should sum to 1, and its length should be equal to the
%              number of distracters. 
%
% OUTPUT:
% imgarray   - search array as an image

% Credits: PramodRT, ZhivagoK, SPArun
% Change log
%     01/09/2013 (Pramod) - First version
%     30/01/2014 (Pramod) - pdfdist is distpdf; setsize,posjitter,boxsize are now optional
%     15/02/2014 (Puneeth)- Fixed a bug in [2 2 4] setsize arrays which sometimes produces 3 item arrays
%     16/09/2017 (Aakash) - Added provision to make unequal size boxes (for reading experiments)

function srcharray = psy_make_srcharray(T,D,setsize,boxsize,targetpos,posjitter,distpdf)
if(~iscell(D)), D = {D}; end

% if T or D is a 2-d array, then convert to color
if(size(T,3)==1), T = repmat(T,[1 1 3]); end; 
for i=1:length(D), if(size(D{i},3)==1), D{i} = repmat(D{i},[1 1 3]); end; end; 

% ---- handle defaults and validate parameters
if(~exist('distpdf')|isempty(distpdf)), nd = size(D,2); distpdf = [ones(1,nd)/nd]; end;
if(length(D)~=size(distpdf,2))
    error('psy_make_srcharray: #distracters are not equal to #probabilities. Check input: pdfdist');
end
if (~exist('setsize')|isempty(setsize)), setsize = [4 4 16]; end
if (length(setsize) == 2), setsize(3) = setsize(1)*setsize(2); end
nrows = setsize(1); ncols = setsize(2); nitems = setsize(3); npos = nrows*ncols; 
if (nitems > (npos)), error('nitems greater than array specs. Check input: setsize'); end
if(~exist('targetpos')||isempty(targetpos)),targetpos = unidrnd(npos); end;

% if a number of targetpos are given, choose one randomly
if(length(targetpos)>1), q = randperm(length(targetpos)); targetpos = targetpos(q(1)); end; 

% find out max long dimension of all T & D images
TD = D; TD{end+1} = T; [x,y,z]=cellfun(@size,TD); maxlongdim = max(max([x y]));
if(~exist('boxsize')||isempty(boxsize)),boxsize = [round(1.5*maxlongdim) round(1.5*maxlongdim)]; end;

% maximum possible position jitter
if(~exist('posjitter')),posjitter=0; end; 
if(exist('posjitter')&& numel(posjitter) == 1), posjitter = [posjitter posjitter]; end % specifies default posjitter
jitter(1) = round(posjitter(1)*boxsize(1));
jitter(2) = round(posjitter(2)*boxsize(2));
% ----- end of handle defaults

% ----- main script
% itemarray is a cell array containing the target & distracter images at required positions
itemarray = cell(nrows,ncols); itemarray{targetpos} = T;
ndist = nitems-1; % number of distracter items in array
numsizes = round(distpdf.*ndist); % number of distracters of each type
qmax = find(numsizes == max(numsizes)); qmax = qmax(1); % index of the type of the distracter having highest number of instances

% adjust number of most-frequent distracters by +-1 so that ndist matches. 
% This could happen becuase of the rounding error in the definition of numsizes
numsizes(qmax) = numsizes(qmax) - (sum(numsizes) - ndist); 

distid = []; % ids of distracters for all distracter positions (e.g. for [3 4 2] numsizes, you'll get [1 1 1 2 2 2 2 3 3]
for i = 1:length(numsizes)
    distid = [distid;i*ones(numsizes(i),1)];
end

distid = distid(randperm(ndist)); % type id of each distracter
lpos = [1:npos/2]; rpos = [lpos(end)+1:npos]; 
lpos(lpos==targetpos)=[]; rpos(rpos==targetpos)=[]; % all left & right positions
if(targetpos<=npos/2) % decide how many distracters on left or right; note that ndist will be odd if nitems is even
    nleft = floor(ndist/2); nright=ndist-nleft; 
else
    nright = floor(ndist/2); nleft=ndist-nright; 
end

% Line 104 Edited by N.C. Puneeth on 15th Feb 2014
% When using randsample on vectors of length 1 use the following format:
% In y = randsample(population,k), if population can have a length of 1,
% use y = population(randsample(length(population),k)) instead

lpos = lpos(randsample(length(lpos),nleft)); rpos = rpos(randsample(length(rpos),nright));
allpos = [lpos rpos]; % this contains only the allowed distracter positions

count=1; 
for colid = 1:ncols
    for rowid = 1:nrows
        itembox = zeros(boxsize(1),boxsize(2),3);

        if(count==targetpos)
            item = T; 
        elseif(any(allpos==count)) % i.e. distracter is present
            q = find(allpos==count);
            item = D{distid(q)};
        else
            srchcellarray{rowid,colid} = itembox; 
            count=count+1; 
            continue;
        end
        
        xsize = size(item,1); ysize = size(item,2);
        % create random x and y jitter relative to center
        x=0; y=0;
        if(jitter(1)~=0), x = randsample(-jitter(1)+1:jitter(1),1); end;
        if(jitter(2)~=0), y = randsample(-jitter(2)+1:jitter(2),1); end; 
        xstart = round((boxsize(1) - xsize)/2)+x; ystart = round((boxsize(2) - ysize)/2)+y;
        if(xstart==0),xstart=1;end; if(ystart==0),ystart=1;end; 
        itembox(xstart:xstart+xsize-1,ystart:ystart+ysize-1,:) = item; 
        srchcellarray{rowid,colid} = itembox; 
        count=count+1; 
    end
end
srcharray = uint8(cell2mat(srchcellarray)); 

end
