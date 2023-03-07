% -------------------------------------------------------------------
% This function initializes the display.
% -------------------------------------------------------------------
% psy_init_display
% REQUIRED INPUTS
%  None
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  None
% METHOD
%
% NOTES
%
% EXAMPLE
%  psy_init_display();
%  will initialize the display
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function screen_str = psy_init_display(scr_num, origin)

global expt_str;

screen_str = struct(...
    'eye_dist_mm', [],...
    'wptr', [],...
    'rect', [],...
    'dva_rect', [],...
    'color', [],...
    'w_mm', [],...
    'h_mm', [],...
    'bpp', [],...
    'w_pix', [],...
    'h_pix', [],...
    'hz', [],...
    'X_mm_per_pix', [],...
    'Y_mm_per_pix', [],...
    'mm_per_dva', [],...
    'x_pix_per_dva', [],...
    'y_pix_per_dva', [],...
    'fields', []);
% ----------------------------------------------------------------------------------
n=0;
n=n+1; screen_str.fields{n,1} = 'eye_dist_mm = distance of the eye from the center of the screen';
n=n+1; screen_str.fields{n,1} = 'wptr     = window pointer';
n=n+1; screen_str.fields{n,1} = 'rect     = screen rectangle coordinates in pixels';
n=n+1; screen_str.fields{n,1} = 'dva_rect = screen rectangle coordinates in dvas';
n=n+1; screen_str.fields{n,1} = 'color    = screen color';
n=n+1; screen_str.fields{n,1} = 'w_mm         = monitor width in mm';
n=n+1; screen_str.fields{n,1} = 'h_mm         = monitor height in mm';
n=n+1; screen_str.fields{n,1} = 'bpp          = bits per pixel';
n=n+1; screen_str.fields{n,1} = 'w_pix        = monitor width in pixels';
n=n+1; screen_str.fields{n,1} = 'h_pix        = monitor height in pixels';
n=n+1; screen_str.fields{n,1} = 'hz           = monitor refresh rate';
n=n+1; screen_str.fields{n,1} = 'X_mm_per_pix = mm per pixel along the width';
n=n+1; screen_str.fields{n,1} = 'Y_mm_per_pix = mm per pixel along the height';
n=n+1; screen_str.fields{n,1} = 'mm_per_dva  = mm per dva';
% ----------------------------------------------------------------------------------

screen_str.eye_dist_mm = 480;

[screen_str.w_mm, screen_str.h_mm] = Screen('DisplaySize', scr_num);

res   = Screen('Resolution', scr_num);
screen_str.bpp   = res.pixelSize;
screen_str.w_pix = res.width;
screen_str.h_pix = res.height;
screen_str.hz    = res.hz;

if ~exist('origin'), origin = [screen_str.w_pix/2 screen_str.h_pix/2]; end

screen_str.origin = origin;

screen_str.X_mm_per_pix = screen_str.w_mm/screen_str.w_pix;
screen_str.Y_mm_per_pix = screen_str.h_mm/screen_str.h_pix;

screen_str.mm_per_dva = screen_str.eye_dist_mm * tand(1);

screen_str.x_pix_per_dva = screen_str.mm_per_dva/screen_str.X_mm_per_pix;
screen_str.y_pix_per_dva = screen_str.mm_per_dva/screen_str.Y_mm_per_pix;

expt_str.specs.screen = screen_str;

screen_str.dva_rect = [psy_pix2dva([0 0])...
                       psy_pix2dva([screen_str.w_pix screen_str.h_pix])];

return