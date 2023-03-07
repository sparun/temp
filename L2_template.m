%% L2 structures 

%% OVERVIEW & VISION
% The L2 structure is a common format data structure for all experiments at Visionlab
% IISc. It is a "Level 2" data structure that compiles essential data from multiple subjects/neurons
% into a single data file. It is self-documenting in the sense that anyone who reads it will be able 
% to quickly understand the data and get to analysis quickly. 

%% COMMON FEATURES OF ALL L2
%   - L2 structures contain data from only ONE distinct experiment (structures that contain data
%     from multiple experiments should ideally be called L3_str, and in practice we have seen this
%     not to be very necessary or convenient) 
%   - All L2 structure have a filename format L2_<task>_<exptname>.mat 
%   - When an L2 file is loaded, it contains only one workspace variable always called L2_str
%   - Relevant data is kept at the top level, and more detailed data in substructures (e.g.
%     L2_str.RT and L2_str.subjinfo.age) 
%   - Fields in the L2_str should be ordered from info/items that change least often (e.g. expt_name, 
%     taskinfo, subjectinfo) in the expt to those that change most often (e.g. RT of 
%     individual subjects)
%   - Every structure should have a fields entry which contains brief description of each of the
%     variables stored 
%   - The L2 structure should contain all data collected, including outliers etc. Your analysis
%     codes can exclude the outliers but your L2 must not, so that your outlier removal step is
%     explicitly visible in code. 
%   - Variables stored should be vectors and matrices as much as possible, and cell
%     arrays/structures/tables only if inevitable. 
%   - Vectors and cell arrays should always be stored as n x 1 NOT 1 x n
%   - The L2 structure typically should not contain derived variables like meanRT etc

% EXAMPLE TEMPLATE FOR PSYCHOPHYSICAL EXPTS(adapt to your data/experiment as you see fit) 
% L2_str.expt_name --> contains a short name of your expt (eg: objword
% L2_str.images    --> n x 1 cell array of images used
% L2_str.task      --> substructure containing task parameters like stim_duration etc. must also
%                      contain a fields variable. 
% L2_str.subjinfo  --> substructure containing the following fields
%                        L2_str.subjinfo.subjID --> n x 1 cell array containing subjectID prefix for
%                        each subject in your expt (e.g. 'S01','S02',etc) - note that we are
%                        anonymizing subjects here, but the expt data folder can contain
%                        de-anonymized files containing subject name etc. 
%                        L2_str.subjinfo.age    --> n x 1 vector of subject age
%                        L2_str.subjinfo.gender --> n x 1 vector of subject gender
%                        L2_str.subjinfo.exptdate --> n x 1 cell array of date on which expt was run
%                        L2_str.subjinfo.exptPC   --> n x 1 cell array of name of PC on which expt was run (if applicable) 
% L2_str.imgpairs  --> npairs x 2 matrix containing target and distractor imageID (matching L2_str.images) of each unique search 
% L2_str.RT        --> npairs x nsubj x nreps matrix containing response times on each correct trial
% L2_str.PC        --> npairs x nsubj matrix containing percent correct on each unique search condition
% L2_str.fields    --> text descriptions of each entry in the top-level of the L2_str

