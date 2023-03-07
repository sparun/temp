% generates a structure with program id's and
% a cell array containing the program names
function mkprognames(ishugo)
global C;
if ~exist('ishugo') | isempty(ishugo), ishugo = 0; end;
if ishugo == 1
    % loading program names -- only for hugo data
    PROG_ID.EYE      =  0;
    PROG_ID.NTX      =  1; progname{PROG_ID.NTX,1}      = 'ntx';
    PROG_ID.DTX      =  2; progname{PROG_ID.DTX,1}      = 'dtx';
    PROG_ID.DTXCT    =  3; progname{PROG_ID.DTXCT,1}    = 'dtxct';
    PROG_ID.DTXRD    =  4; progname{PROG_ID.DTXRD,1}    = 'dtxrd';
    PROG_ID.SRCH     =  5; progname{PROG_ID.SRCH,1}     = 'srch';
else
    PROG_ID.EYE      =  1; progname{PROG_ID.EYE,1}      = 'eye';
    PROG_ID.SRCH     =  2; progname{PROG_ID.SRCH,1}     = 'srch';
    PROG_ID.NTX      =  3; progname{PROG_ID.NTX,1}      = 'ntx';
    PROG_ID.DTX      =  4; progname{PROG_ID.DTX,1}      = 'dtx';
    PROG_ID.DTXCT    =  5; progname{PROG_ID.DTXCT,1}    = 'dtxct';
    PROG_ID.DTXRD    =  6; progname{PROG_ID.DTXRD,1}    = 'dtxrd';
    PROG_ID.FG       =  7; progname{PROG_ID.FG,1}       = 'fg';
    PROG_ID.ORD      =  8; progname{PROG_ID.ORD,1}      = 'ord';
    PROG_ID.PRIME    =  9; progname{PROG_ID.PRIME,1}    = 'prime';
    PROG_ID.HOLES    = 10; progname{PROG_ID.HOLES,1}    = 'holes';
    PROG_ID.OCC      = 11; progname{PROG_ID.OCC,1}      = 'occ';
    PROG_ID.OCC2     = 12; progname{PROG_ID.OCC2,1}     = 'occ2';
    PROG_ID.SIZEL    = 13; progname{PROG_ID.SIZEL,1}    = 'sizel';
    PROG_ID.SIZE     = 14; progname{PROG_ID.SIZE,1}     = 'size';
    PROG_ID.ASY      = 15; progname{PROG_ID.ASY,1}      = 'asy';
    PROG_ID.PARTS    = 16; progname{PROG_ID.PARTS,1}    = 'parts';
    PROG_ID.VIEW     = 17; progname{PROG_ID.VIEW,1}     = 'view';
    PROG_ID.SRCHG    = 18; progname{PROG_ID.SRCHG,1}    = 'srchg';
    PROG_ID.SLEEP    = 19; progname{PROG_ID.SLEEP,1}    = 'sleep';
    PROG_ID.VIEWCT   = 20; progname{PROG_ID.VIEWCT,1}   = 'viewct';
    PROG_ID.IMP      = 21; progname{PROG_ID.IMP,1}      = 'imp';
    
    PROG_ID.GVIEW    = 22; progname{PROG_ID.GVIEW,1}    = 'gview';
    PROG_ID.KNOW     = 23; progname{PROG_ID.KNOW,1}     = 'know';
    PROG_ID.TVIEW    = 24; progname{PROG_ID.TVIEW,1}    = 'tview';
    PROG_ID.AFFINE   = 25; progname{PROG_ID.AFFINE,1}   = 'affine';
    
    PROG_ID.SHADOWG  = 26; progname{PROG_ID.SHADOWG,1}  = 'shadowg';
    PROG_ID.SHADOWL  = 27; progname{PROG_ID.SHADOWL,1}  = 'shadowl';
    PROG_ID.OKNOW    = 28; progname{PROG_ID.OKNOW,1}    = 'oknow';
    
    PROG_ID.ASP      = 29; progname{PROG_ID.ASP,1}      = 'asp';
    PROG_ID.BATON    = 30; progname{PROG_ID.BATON,1}    = 'baton';
    
    PROG_ID.VSP      = 31; progname{PROG_ID.VSP,1}      = 'vsp';
    PROG_ID.VST      = 32; progname{PROG_ID.VST,1}      = 'vst';
    
    PROG_ID.CAPTCHA  = 33; progname{PROG_ID.CAPTCHA,1}  = 'captcha';
    PROG_ID.INVAR    = 34; progname{PROG_ID.INVAR,1}    = 'invar';
    PROG_ID.SELTOL   = 35; progname{PROG_ID.SELTOL,1}   = 'seltol';
    PROG_ID.OKNOWL   = 36; progname{PROG_ID.OKNOWL,1}   = 'oknowl';
    
    
    PROG_ID.FVIEW    = 37; progname{PROG_ID.FVIEW,1}    = 'fview';
    PROG_ID.CNTMT    = 38; progname{PROG_ID.CNTMT,1}    = 'cntmt';
    PROG_ID.FGF      = 39; progname{PROG_ID.FGF,1}      = 'fgf';
    PROG_ID.REL      = 40; progname{PROG_ID.REL,1}      = 'rel';
    
	PROG_ID.GVIEWS3  = 41; progname{PROG_ID.GVIEWS3,1}  = 'gviews3';
    PROG_ID.AFFINE2  = 42; progname{PROG_ID.AFFINE2,1}  = 'affine2';
    PROG_ID.RSURF    = 43; progname{PROG_ID.RSURF,1}    = 'rsurf';
    
    PROG_ID.RTUNE    = 44; progname{PROG_ID.RTUNE,1}    = 'rtune';
end
C.PROG_ID = PROG_ID;
C.progname = progname;
end