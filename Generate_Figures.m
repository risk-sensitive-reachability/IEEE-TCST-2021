%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Convenience method for generating all figures in 
%   Smith and Chapman 2021, On Exponential Utility and Conditional 
%   Value-at-Risk as Risk-Averse Performance Criteria. 
%
%   NOTE: This method will first fulfill all computational prerequisites
%   for a given figure, which could take a substantial amount of time. 
%   If you need to stop computations, Generate_Figures() can be called 
%   again and it will try to pick up where things left off. 
%
%   For faster computation times, you may want to fulfill the 
%   computational prerequisties in parallel (i.e., one prerequistie 
%   per computer, by making individual calls to Run_Recursion and
%   and Plot_Tradeoffs as described in the README.me in the root of this
%   repository).
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[] = Generate_Figures()

    % get a directory for saving figures
    % - handle windows filepaths
    % - create directory it doesn't exist
    slash = '/'; if (ispc); slash = '\'; end
    directory = strcat('IEEE-TCST-2021',slash,'figures');
    if (~exist(directory, 'dir')); mkdir(directory); end

    for figure_number = 1:13
        file_path = fullfile(strcat(directory,slash,'figure_',num2str(figure_number)));
        figure_plotter = str2func(strcat('plot_figure_', mat2str(figure_number)));
        figure_plotter(file_path);
        close all;
    end

end