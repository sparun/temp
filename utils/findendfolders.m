% this function finds all the terminal folders from a given root folder
% for eg.,  if the directory structure is as follows:
%     root
%        |_ folder1
%        |        |_folder1-1 (terminal folder)
%        |_ folder2 (terminal folder)
%        |_ folder3
%                 |_folder3-1
%                           |_folder3-1-1 (terminal folder)
%                 |_folder3-2 (terminal folder)
% the output of this function will be a cell array of size 4x1 with the
% following folder names
%    1) root\folder1\folder1-1
%    2) root\folder2
%    3) root\folder3\folder3-1\folder1-1
%    3) root\folder3\folder3-3
%
% Zhivago Kalathupiriyan
% 14 AUG 2013

function findendfolders(rootfolder)

% using global variables to store the results since this
% is a recursive function
global folderlist counter;

if ispc , slstr = '\'; else slstr = '/'; end

lst = dir(rootfolder); % contents of the folder
q = getsubfolders(lst); % indices to the subfolders

if isempty(q)
    % if there are no subfolders, add this to the final folder list
    % fprintf('%s\n', rootfolder);
    folderlist{counter,1} = rootfolder;
    counter = counter + 1;
else
    % if there are subfolders, recirsively call this function
    for i = q
        findendfolders([rootfolder slstr lst(i).name]);
    end
end
end

% function to get indices to only the subfolders in a given folder
% lst should be the output of the dir function
function q = getsubfolders(lst)
q = [];
for i = 1:length(lst)
    % ignoring the currrent and parent folders
    if strcmp(lst(i).name, '.') | strcmp(lst(i).name, '..'), continue; end
    % store the index if it's a folder
    if lst(i).isdir
        q = [q i];
    end
end
end