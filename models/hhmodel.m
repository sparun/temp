% hhmodel          -> Hodgkin-Huxley single-compartment model
% Required inputs
%    current       = nsamples x 1 vector of external current in nA
% Optional inputs:
%    tin           = n x 1 vector of time points of external current in s
%                    if not given, current is assumed to be in steps of 1 ms
%    parameters    = [ENa EK EL gNa gK gL Cm]
%                        ENa = Na reversal potential    (default = 55 mV)
%                        EK  = K reversal potential     (default = -72 mV)
%                        EL  = leak reversal potential  (default = -49 mV)
%                        gNa = maximum channel conductance of Na (default = 120 mS/cm^2)
%                        gK  = maximum channel conductance of K (default = 36 mS/cm^2)
%                        gL  = maximum channel conductance of Leakage Channel (default = 0.3 mS/cm^2)
%                        Cm  = membrane capacitance (default = 1 uF/cm^2)
%    init          = vector specifying initial values of [V n m h]
%                       V = Initial membrane volatage  (default = -60 mV )
%                       m = Na channel gating variable (default = 0.4)
%                       n = K channel gating variable  (default = 0.1)
%                       h = K channel gating variable  (default = 0.8)
% Outputs
%    Vm            = output membrane potential in mV
%    tout          = time points for membrane potential in s
%
% References
%    Chapter 6 of Johnston and Wu
%    http://www.its.caltech.edu/~matilde/HodgkinHuxleyModel.pdf
% Example
%    current = 0.7*ones(100,1); [Vm,tout] = hhmodel(current); plot(tout,Vm); 
% ChangeLog
%    9/1/2018 - Arun/Georgin - first version

function [Vm,tout] = hhmodel(current,tin,hhparams,hhinit)
if ~exist('tin','var'), tin = [0:length(current)-1];end;
if ~exist('hhparams','var'),hhparams=[55;-72;-49;1.2;0.36;0.003;0.01]; end
if ~exist('hhinit','var'),hhinit=[-60;0.4;0.1;0.8];end;

tout = [0:0.1:tin(end)]; % solve ODE in 0.1ms timesteps
[~,X] = ode15s(@(t,X) hhmod_inst(t,X,hhparams,current,tin),tout,hhinit);
Vm=X(:,1); 

%n=X(:,2); m=X(:,3); h=X(:,4); % enable to output other state variables

end

% hhmod_inst calculates the instantaneous values of each parameter
function dX = hhmod_inst(t,X,hhparams,iextvec,tSpan)
V=X(1);n=X(2);m=X(3);h=X(4);

ENa = hhparams(1); EK = hhparams(2); EL = hhparams(3);
gNa = hhparams(4); gK = hhparams(5); gL = hhparams(6); Cm  = hhparams(7);

iExt=interp1(tSpan,iextvec,t); % interpolate current to find value at t

% instantaneous conductances
gK_ins = (n^4)*gK; gNa_ins = (m^3)*h*gNa;

% ionic currents
iL=gL*(V-EL); iNa=gNa_ins*(V-ENa); iK=gK_ins*(V-EK);

% Rate Constants - n
alpha_n = 0.01*((V+50))/(1-exp(-(V+50)/10)); beta_n = 0.125*exp(-(V+60)/80);
% Rate Constants - m
alpha_m = 0.1*((V+35))/(1-exp(-(V+35)/10)); beta_m = 4*exp(-(V+60)/18);
% Rate constants - h
alpha_h = 0.07*exp(-(V+60)/20); beta_h = 1/(exp((-(V+30))/10)+1);

% differential equations
dV=(iExt+-(iL+iNa+iK))/Cm;
dn=alpha_n*(1-n)-beta_n*n;
dm=alpha_m*(1-m)-beta_m*m;
dh=alpha_h*(1-h)-beta_h*h;

dX=[dV;dn;dm;dh];

end
