%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Create a disturbance profile for the stormwater system
% INPUT:
    % type = type of probability distribution
    %   one of: 'major left skew', 'minor left skew',
    %      'major right skew', 'minor right skew'
% OUTPUT:
    % ws = a disturbance realization
    % P = a probability mass function for the ws
    % nw = number of elements in ws
    % wunits = units of disturbance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

function [ws, P, nw, wunits] = get_runoff_disturbance_profile(type)

    switch type 
        case 'major left skew'
            ws = [0.00;1.05;1.76;2.46;3.17;3.87;4.59;5.06;5.29;5.53;6.00];
            P = [0.002170861, 0.013590957, 0.036866629, 0.082343164, 0.15143715, 0.229287412, 0.262879644, 0.140542581, 0.061912919, 0.017592806, 0.001375877]; 

        case 'minor left skew'
            ws = [0.25;1.39;2.25;2.85;3.45;4.31;4.95;5.30;5.65;6.01;6.50];
            P = [0.001455955, 0.016336835, 0.064224434, 0.132152853, 0.22060712, 0.269438474, 0.160125253, 0.086963721, 0.036374021, 0.010971826, 0.001349508];

        case 'minor right skew'
            ws = [1.50;2.31;2.75;3.05;3.85;4.50;4.85;5.28;6.02;6.76;7.50];
            P = [0.001410388,0.040140548,0.113152012,0.174706481,0.234886345,0.171983589,0.130456147,0.08603905,0.034163381,0.010537311,0.002524749];

        case 'major right skew'
            ws = [1.75;2.34;2.59;2.85;3.62;4.20;4.90;5.60;6.35;7.20;8.00];
            P = [0.000324124,0.025518452,0.078925878,0.159891818,0.254778305,0.208558908,0.139802993,0.079855225,0.036695129,0.012174648,0.003474521];
        otherwise
            error('distribution type is not supported')
    end
    
    nw = length(ws);
    
    ws = ws'; % this version requires a row vector of disturbances 
    P = P';   % this version requires a column vector of probabilities
    
    if abs(sum(P)-1.00) >= 0.00001
        error('sum(P) not equal to 1'); 
    end
    
    wunits = 'cfs';

end