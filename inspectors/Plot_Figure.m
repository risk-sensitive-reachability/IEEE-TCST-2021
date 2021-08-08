%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Convenience method for generating the figures in 
%   Smith and Chapman 2021, On Exponential Utility and Conditional 
%   Value-at-Risk as Risk-Averse Performance Criteria. 
% INPUT:
%   figure_number = the numeric identifier of the figure
%   file_path [optional] = a base filename for the figures
%       (e.g., 'path/to/file/figure_n'); if a figure produces multiple
%       files, this filename will be used as a prefix. defaults to
%       'IEEE-TCST-2021/figures/figure_n'
% OUTPUTS:
%   [file(s)]
%       path/to/figure/figure_*.pdf : one or more PDFs
%       corresponding to the specified figure in the paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[] = Plot_Figure(figure_number, file_path)

    if ~exist('file_path','var')
        % get a directory for saving figures
        % - handle windows filepaths
        % - create directory it doesn't exist
        slash = '/'; if (ispc); slash = '\'; end
        directory = strcat('IEEE-TCST-2021',slash,'figures');
        if (~exist(directory, 'dir')); mkdir(directory); end

        % build full file path
        file_path = fullfile(strcat(directory,slash,'figure_',num2str(figure_number)));
    end

    close all;

    if figure_number < 0 || figure_number > 13
        error('not a supported figure');
    else
        figure_plotter = str2func(strcat('plot_figure_', mat2str(figure_number)));
        figure_plotter(file_path);
    end

    close all;
    
end