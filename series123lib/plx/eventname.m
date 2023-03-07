function evname = eventname(code)
codes = {'TRIAL START', 300
         'TRIAL STOP', 301
         'EYEDATA START', 302
         'EYEDATA STOP', 303
         'LEFT TARGET ON', 400
         'LEFT TARGET FIXATED', 401
         'LEFT TARGET REWARD', 402
         'RIGHT TARGET ON', 403
         'RIGHT TARGET FIXATED', 404
         'RIGHT TARGET REWARD', 405
         'DOWN TARGET ON', 406
         'DOWN TARGET FIXATED', 407
         'DOWN TARGET REWARD', 408
         'REWARDED', 600
         'FIX SPOT ON', 6000
         'FIX ATTAINED', 6001
         'S0 ON', 6010
         'S0 OFF', 6011
         'S1 ON', 6012
         'S1 OFF', 6013
         'S2 ON', 6014
         'S2 OFF', 6015
         'S3 ON', 6016
         'S3 OFF', 6017
         'S4 ON', 6018
         'S4 OFF', 6019
         'S5 ON', 6020
         'S5 OFF', 6021
         'S6 ON', 6022
         'S6 OFF', 6023
         'S7 ON', 6024
         'S7 OFF', 6025
         'S8 ON', 6026
         'S8 OFF', 6027
         'S9 ON', 6028
         'S9 OFF', 6029
         'END ANALYSIS', 6050
         'RESPONSE CORRECT', 6100
         'RESPONSE WRONG', 6101
         'START XFER', 17000
         'END XFER', 17001
         'FILENAME BEGIN', 17002
         'FILENAME END', 17003
         'FILE BEGIN', 17004
         'FILE END', 17005};
x = cell2mat(codes(:,2));
evname = [];
q = find(x == code);
if ~isempty(q), evname = codes{q,1}; end
end