%Create2DLine      --> Create a 2D oriented line with specified parameters
% Grating = Create2DLine(width,theta,n)
% Required inputs
%    theta         = orientation of the line (degrees cw from vertical)
% Optional inputs
%    linelength    = length of line in pixels (default = 100 pixels)
%    relwidth      = width of line in units of linelength (default = 0.1)
%    relframesize  = frame size in which to embed line, in units of linelength (default = 1.5)
% Outputs:
%    Line          = square matrix containing the oriented line 

% SP Arun
% ChangeLog: 
%    20/03/2008 - SPA     - first version
%    13/11/2015 - SPA/SF  - revamped entire function

function Line = Create2DLine(theta,linelength,relwidth,relframesize)
if(~exist('relwidth')), relwidth = 0.1; end; 
if(~exist('linelength')), linelength = 100; end; 
if(~exist('relframesize')), relframesize = 1.5; end; 
if(relframesize<=1), error('Framesize should be larger than line length'); end; 

% convert everything into pixel units
width = round(relwidth*linelength); framesize = round(relframesize*linelength); 

% generate line
img = ones(linelength,width); % this is the basic line
Line = imrotate(img,-theta); 
Line = pad(Line,framesize); 

return