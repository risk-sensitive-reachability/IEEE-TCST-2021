%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Create a disturbance profile for the thermostatic regulator system
% INPUT:
    % type = type of probability distribution
    %   one of: 'right skew', 'left skew', 'no skew'
% OUTPUT:
    % ws = a disturbance realization
    % P = a probability mass function for the ws
    % nw = number of elements in ws
    % wunits = units of the disturbance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

function [ws, P, nw, wunits] = get_temperature_disturbance_profile(type)

    ws = [-0.500000,-0.458333,-0.416667,-0.375000,-0.333333,-0.291667,-0.250000,-0.208333,-0.166667,-0.125000,-0.083333,-0.041667,0.000000,0.041667,0.083333,0.125000,0.166667,0.208333,0.250000,0.291667,0.333333,0.375000,0.416667,0.458333,0.500000];
    switch type 
        case 'left skew'
            P = [0.00107870;0.00167360;0.00254120;0.00377610;0.00549130;0.00781500;0.01088440;0.01483550;0.01978900;0.02583270;0.03300190;0.04126020;0.05048340;0.06044870;0.07083530;0.08123290;0.09115160;0.09989590;0.10565740;0.10328460;0.08536480;0.05335700;0.02290860;0.00632340;0.00107680];
        case 'no skew'
            P = [0.0010230;0.0021300;0.0041610;0.0076250;0.0131120;0.0211530;0.0320180;0.0454680;0.0605800;0.0757290;0.0888180;0.0977330;0.1009000;0.0977330;0.0888180;0.0757290;0.0605800;0.0454680;0.0320180;0.0211530;0.0131120;0.0076250;0.0041610;0.0021300;0.0010230];          
        case 'right skew'
            P = [0.00107680;0.00632340;0.02290860;0.05335700;0.08536480;0.10328460;0.10565740;0.09989590;0.09115160;0.08123290;0.07083530;0.06044870;0.05048340;0.04126020;0.03300190;0.02583270;0.01978900;0.01483550;0.01088440;0.00781500;0.00549130;0.00377610;0.00254120;0.00167360;0.00107870;];
        otherwise
            error('distribution type is not supported')
    end
    
    nw = length(ws);
    
    if abs(sum(P)-1.00) >= 0.00001
        error('sum(P) not equal to 1'); 
    end
    
    wunits = 'deg C';

end