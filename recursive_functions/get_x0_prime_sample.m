%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Samples an initial condition with units x0prime = x0 - b
%   for the thermostatic regulator under LEQG control. Recall that dynamics 
%   of thermostatic regulator for LEQG are: 
%       (xk+1 - b) = A * (xk - b) + B * uk + wk and xkprime = xk - b
%   
%   Note: This approach assumes that x0prime is normally distributed with 
%   a small variance compared to variance of wk and has mean 
%   given by x0 - b
%
% INPUT:
%   x0 : the initial temperature deg C. 
%   config : configuration struct
%   scenario : scenario struct
%   stream : a psuedorandom number stream 
% OUTPUT:
%   x0prime_sample = a random sample of x0'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  x0prime_sample = get_x0_prime_sample(x0, config, scenario, stream)

    [~, ~, ~, ~, b] = therm_ctrl_load_parameters(config);

    %   scenario.variance = 0.03 is variance of wk, we want variance of
    %   x0prime to be smaller to simulate a situation in which we some
    %   adequate certainty about the location of initial condition 
    %   (to compare to our other scenarios)
    x0prime_variance = scenario.variance/100; 

    x0prime_std = sqrt(x0prime_variance);

    x0prime_mean = x0 - b;

    % Generate values from a normal distribution with mean 1
    % and standard deviation 2.
    % r = 1 + 2.*randn(100,1);
    x0prime_sample = x0prime_mean + x0prime_std * randn(stream, 1);

end
  