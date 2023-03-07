// Common Plexon related constants and function declarations
// USAGE: #include "plx.h" at the beginning of the file
//
// Zhivago Kalathupiriyan
// 10 SEP 2011

// Change Log:
// Added 6 event codes specific to Occknow Expt
// N.C. PUNEETH
// 10 JULY 2014

// externs declaration
#define allocation_flag  _int0
#define loc              _int1
#define XX               _pfloat1
#define YY               _pfloat2
#define P                _pint0
#define obj_id           _int2
#define abort_trial_flag _int3
#define reward_time      _int4
#define reward_clicks    _int5
#define good_pause       _int6
#define bad_pause        _int7

// codes used while sending alphabets
#define UCASE_ASCII 65
#define LCASE_ASCII 97

// codes for valid neuron id's
#define NEURON_ID_MIN        1
#define NEURON_ID_MAX        128

// codes to mark start/end of a trial
#define PLEXON_START         300
#define PLEXON_STOP          301

// codes to mark start/end of eye data collection
// also meant as a backup in case of a failure in
// dropping the trial start/stop codes 
#define EYEDATA_START        302
#define EYEDATA_STOP         303

// codes for validation of eye calibration
#define LEFT_TARGET_ON       400
#define LEFT_TARGET_FIXATED  401
#define LEFT_TARGET_REWARD   402
#define RIGHT_TARGET_ON      403
#define RIGHT_TARGET_FIXATED 404
#define RIGHT_TARGET_REWARD  405
#define DOWN_TARGET_ON       406
#define DOWN_TARGET_FIXATED  407
#define DOWN_TARGET_REWARD   408

// codes to mark the reward time
#define REWARDED             600

// codes for valid block id's
#define BLOCK_ID_MIN         900
#define BLOCK_ID_MAX         999

// codes for valid conditions
#define COND_ID_START        1000
#define COND_ID_END          4999

// codes for fixations
#define FIX_SPOT_ON          6000
#define FIX_ATTAINED         6001

// codes for stimulus presentation during a trial
#define STIM0_ON             6010
#define STIM0_OFF            6011
#define STIM1_ON             6012
#define STIM1_OFF            6013
#define STIM2_ON             6014
#define STIM2_OFF            6015
#define STIM3_ON             6016
#define STIM3_OFF            6017
#define STIM4_ON             6018
#define STIM4_OFF            6019
#define STIM5_ON             6020
#define STIM5_OFF            6021
#define STIM6_ON             6022
#define STIM6_OFF            6023
#define STIM7_ON             6024
#define STIM7_OFF            6025
#define STIM8_ON             6026
#define STIM8_OFF            6027
#define STIM9_ON             6028
#define STIM9_OFF            6029

// Leaving a gap in the series just in case its needed
// for adding other stimuli

// codes specific to the occknow experiment
#define MOVE_START           6040
#define OCC_ENTER            6041
#define FULL_ENTER           6042
#define OCC_EXIT             6043
#define FULL_EXIT            6044
#define MOVE_STOP            6045

// codes to mark the last stimulus presented
// this also allows looking at the next stimulus
// presentation time during online analysis
#define END_ANALYSIS         6050

// codes for trial outcome
#define RESPONSE_CORRECT     6100
#define RESPONSE_WRONG       6101

// codes for permutation order
#define PERM_ORDER_START     6200
#define PERM_ORDER_END       6210

// codes for valid program id's
#define PROG_ID_START        8000
#define PROG_ID_END          9000

// codes for valid 1-letter version
// A=10001, B=10002, .... Z=10026
#define VERSION_START        9001
#define VERSION_END          9026

// codes for sending program name
#define PROG_NAME_START      9100
#define PROG_NAME_END        9101

// codes for valid 2-letter monkey name
// A=10001, B=10002, .... Z=10026
#define MONKEY_NAME_START    10001
#define MONKEY_NAME_END      10026

// codes for sending AP/ML information
// allowing a maximum of 99 +ve and 99 -ve grid points
#define AP0                  10200
#define ML0                  10400

// code for valid 3-digit track id's
#define TRACK_ID_START       11000
#define TRACK_ID_END         12000

// code for valid 1-letter track location
// a=10001, b=10002, .... z=10026
#define TRACK_LOC_START      12001
#define TRACK_LOC_END        12026

// For an electrode depth of 12345 micrometers,
// TWO codes will be dropped in the following order
// 1) 16123
// 2) 16045

// codes for first 3 digits of electrode depth (in micrometers)
#define DEPTH_FIRST3_START   15000
#define DEPTH_FIRST3_END     15999

// codes for last 3 digits of electrode depth (in micrometers)
#define DEPTH_LAST3_START    16000
#define DEPTH_LAST3_END      16999

// codes for transfering files
#define START_XFER           17000
#define END_XFER             17001
#define FILENAME_BEGIN       17002
#define FILENAME_END         17003
#define FILE_BEGIN           17004
#define FILE_END             17005

// PROGRAM ID'S
// NOTE: Please APPEND new program id's
#define EYE_PROG_ID     (PROG_ID_START +  1)
#define SRCH_PROG_ID    (PROG_ID_START +  2)
#define NTX_PROG_ID     (PROG_ID_START +  3)
#define DTX_PROG_ID     (PROG_ID_START +  4)
#define DTXCT_PROG_ID   (PROG_ID_START +  5)
#define DTXRD_PROG_ID   (PROG_ID_START +  6)
#define FG_PROG_ID      (PROG_ID_START +  7)
#define ORD_PROG_ID     (PROG_ID_START +  8)
#define PRIME_PROG_ID   (PROG_ID_START +  9)
#define HOLES_PROG_ID   (PROG_ID_START + 10)
#define OCC_PROG_ID     (PROG_ID_START + 11)
#define OCC2_PROG_ID    (PROG_ID_START + 12)
#define SIZEL_PROG_ID   (PROG_ID_START + 13)
#define SIZE_PROG_ID    (PROG_ID_START + 14)
#define ASY_PROG_ID     (PROG_ID_START + 15)
#define PARTS_PROG_ID   (PROG_ID_START + 16)
#define VIEW_PROG_ID    (PROG_ID_START + 17)
#define SRCHG_PROG_ID   (PROG_ID_START + 18)
#define SLEEP_PROG_ID   (PROG_ID_START + 19)
#define VIEWCT_PROG_ID  (PROG_ID_START + 20)
#define IMP_PROG_ID     (PROG_ID_START + 21)
#define GVIEW_PROG_ID   (PROG_ID_START + 22)
#define KNOW_PROG_ID    (PROG_ID_START + 23)
#define TVIEW_PROG_ID   (PROG_ID_START + 24)
#define AFFINE_PROG_ID  (PROG_ID_START + 25)

#define SHADOWG_PROG_ID (PROG_ID_START + 26)
#define SHADOWL_PROG_ID (PROG_ID_START + 27)
#define OKNOW_PROG_ID (PROG_ID_START + 28)

#define ASP_PROG_ID (PROG_ID_START + 29)
#define BATON_PROG_ID (PROG_ID_START + 30)

#define VSP_PROG_ID (PROG_ID_START + 31)
#define VST_PROG_ID (PROG_ID_START + 32)

#define CAPTCHA_PROG_ID (PROG_ID_START + 33)
#define INVAR_PROG_ID (PROG_ID_START + 34)

#define SELTOL_PROG_ID (PROG_ID_START + 35)
#define OKNOWL_PROG_ID (PROG_ID_START + 36)

#define FVIEW_PROG_ID (PROG_ID_START + 37)
#define CNTMT_PROG_ID (PROG_ID_START + 38)

#define FGF_PROG_ID (PROG_ID_START + 39)
#define REL_PROG_ID (PROG_ID_START + 40)
#define GVIEWS3_PROG_ID (PROG_ID_START + 41)
#define AFFINE2_PROG_ID (PROG_ID_START + 42)
#define RSURF_PROG_ID (PROG_ID_START + 43)
#define RTUNE_PROG_ID (PROG_ID_START + 44)

#define PLX_DEV        1
#define PLX_PORT_LSB   0x0
#define PLX_PORT_MSB   0x1
#define PLX_PORT_CTRL  0x2
#define PLX_STROBE_ON  0x03
#define PLX_STROBE_OFF 0x02
#define PLX_START      0x02
#define PLX_STOP       0x00

void start_plexon();
void write_plexon(int code);
void stop_plexon();
void rate_response(int fail_flag);
void inter_trial_interval(int flag, int gpause, int bpause);

int K;
int repeat_flag;
int block_num;
int max_blocks;
int max_conds;
int num_correct;
int num_trials;

int i;
float ntrials;
int ncorrect;
char circular_buffer[21];

void await_fixation();
void check_fixation();
void give_reward();

