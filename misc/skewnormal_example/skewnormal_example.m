%
%   Simple Skew-Normal Example with Quadradic Costs
%   
%   See also the Mathematica notebook 'skewnormal_example.nb' which was 
%   used to create the data files used in this script. 
%
%   This script creates the following plots in the staging/skewnormal/example directory
%       - skewnormal_probability_distribution.pdf : an analytical probability distribution for W ~ skewnormal
%       - skewnormal_phi_empirical_pdf.pdf : an emprical probability distribution for phi(u,W) for u = 0 and u = 0.25
%       - skewnormal_phi_contours.pdf : a figure comparing the contours of phi(u,W) and the probability distribution of W
%       - skewnormal_mean_variance_tradeoff.pdf : mean-variance tradeoff curve for phi(u,W)
%       - skewnormal_minimize_certainty_equivalent.pdf : a figure showing certainty equivalent curves of phi(u, W), and optimal values of phi(u*,W), for varying gamma
%       - skewnormal_ce_curves.pdf : same as the above (but only the first plot)
%       - skewnormal_minimize_cvar.pdf : a vigure showing CVaR curves of phi(u,W), and optimal values of phi(u*,W), for varying alpha
%       - skewnormal_cvar_curves.pdf : same as the above (but only the first plot
%

%% Part 0: Setup
set(0, 'defaultTextInterpreter', 'latex');
set(0, 'defaultAxesTickLabelInterpreter', 'latex');
set(0, 'defaultLegendInterpreter', 'latex'); 

slash = '/'; if (ispc); slash = '\'; end
plot_directory = strcat('IEEE-TCST-2021',slash,'misc',slash,'skewnormal_example',slash,'plots',slash);
if (~exist(plot_directory, 'dir')); mkdir(plot_directory); end

%% Part I: Plot PDF of W ~ Skewnormal
%
% w is skewnormal with parameters:
%   location = 1.052209643
%   scale = 1.451601
%   shape = -2.17376
%
% which means w has the following statistics:
%   mean(w) = 0
%   variance(w) = 1; 
%   skew(w) = -0.5
%   
% the above statistics can be found analytically in Mathematica
%   
%   dist = SkewNormalDistribution[1.052209643, 1.451601, -2.173758];
%   Dataset[{{"Mean", Mean@dist}, {"Variance", Variance@dist}, {"Skew", Skewness@dist}}]
%
% the PDF of W can be found analytically in Mathematica
% PDF[SkewNormalDistribution[1.0522, 1.4516, -2.17376], x]
% 
% the Matlab equivalent is
snpdf = @(x) 0.274829 * exp(-0.237288 * (-1.0522 + x)^2) * erfc(1.05889 * (-1.0522 + x));

% the pdf of W looks like
figure
fplot(snpdf, 'LineWidth', 2);
title('Probability distribution of $$W$$'); 
ylim([0, 0.45]); xlim([-4, 3]);
ylabel('Density'); xlabel('$$w$$');

% save the image
output_filename = strcat(plot_directory, 'skewnormal_probability_distribution');
set(gcf,'Units','Inches'); 
pos = get(gcf, 'Position'); 
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,output_filename,'-dpdf','-r0')

%% Part II: Plot contours of the cost function, phi(u,w) & compare with pdf(W)
%
% Define a cost function phi(u, w)
%    phi(u, w) = u^2 + (w+u)^2; 
%
% The contour plot of phi(u, w) shows that
%   for u = 0
%       phi @ mean(w) = 0
%       phi @ quantile(w, 0.025) ~ 5
%       phi @ quantile(w, 0.975) ~ 3
%
%   for u = 0.25
%       phi @ mean(w) = 0.125 (increased from 0 compared to u = 0)
%       phi @ quantile(w, 0.025) ~ 4 (decreased from 5 compared to u = 0)
%       phi @ quantile(w, 0.975) ~ 4 (increased from 3 compared to u = 0)
%
% start by plotting the contours of phi(u, w)
%   (see figure_plotters/plot_figure_1.m for details)
output_filename = strcat(plot_directory, 'skewnormal_phi_contours');
plot_figure_1(output_filename);  

%% Part III: Plot emprical pdf for phi(u,W)
%
% The pdfs of phi(u,W) for different u can be sampled in Mathematica
% 
% Here we consider a pdf for u = 0 and u = 0.25 and take 1E7 samples from each pdf
%   umin = 0; umax = 0.25;
%   costDistributions = 
%     Table[SeedRandom[0]; 
%   RandomVariate[
%    TransformedDistribution[u^2 + (W + u)^2, W \[Distributed] dist], 
%    10000000], {u, umin, umax, 0.25}];
%
%  Load the pre-computed data from Mathematica
%   'controls' is a vector of values of u from 0 to 0.25 by 0.001
%   'tenMillionSamples' is a matrix of samples drawn from the pdfs of phi
%       the columns correspond to u = 0 and u = 0.25
%       the rows correspond to the us in 'controls'
% 
controls = load('skewnormal_example_controls.mat', 'Expression1').Expression1; 
tenMillionSamples = nan(2, 1E7); 
for i = 1:2
    tenMillionSamples(i,:) = load(strcat('skewnormal_example_phi_1E7_samples_',mat2str(i),'.mat'), 'Expression1').Expression1;
end

% plot emprical pdfs for u = 0 and u = 0.25
close all;
map = gray(3); 
for uindex = [2, 1]
    x = tenMillionSamples(uindex,:);
    % this method essentially draws a curve through the centers of the tops of the histogram bins
    % it makes it easier to see the subtle difference in the two distributions at the extremes
    % u = 0 and u = 0.25
    [N,edges] = histcounts(x,'Normalization','probability');
    edges = edges(2:end) - (edges(2)-edges(1))/2;
    plot(edges, N, 'Color', map(uindex,:), 'LineWidth', 3);
    hold on
end

xlim([0,5])
ylim([0,.12])
title('Empirical probability distribution of $$\phi$$ for u = 0 and u = 0.25'); 
ylabel('probability density');
xlabel('$$\phi$$'); 

legend(...
    strcat('u = ', mat2str(controls(end))), ...
    strcat('u = ', mat2str(controls(1)))); 
hold off; 

% save the image
output_filename = strcat(plot_directory, 'skewnormal_phi_empirical_pdfs');
set(gcf,'Units','Inches'); 
pos = get(gcf, 'Position'); 
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,output_filename,'-dpdf','-r0')

%% Part IV: Plotting the Mean-Variance Tradeoff
%
% The means and variance of of phi for different u can be found analytically in Mathematica
% umin = 0.00; umax = 0.25; du = 0.001; 
% means = Table[
%    Mean@TransformedDistribution[u^2 + (W + u)^2, W \[Distributed] dist], {u, umin, umax, du}];
% variances = 
%  Table[Variance@TransformedDistribution[u^2 + (W + u)^2, W \[Distributed] dist], {u, umin, umax, du}];
%
% Load the pre-computed data from Mathematica, noting that the elements of these 
% vectors correspond to the elements in 'controls' which was previousluy loaded
%   'means' is a vector of mean(phi(u))
%   'variances' is a vector of variance(phi(u))
%   (see figure_plotters/plot_figure_2.m for details)

output_filename = strcat(plot_directory, 'skewnormal_mean_variance_tradeoff');
plot_figure_2(output_filename); 

%% Load required files for Part V
%
% get path to skewnormal input files
slash = '/'; if (ispc); slash = '\'; end
directory = strcat('IEEE-TCST-2021',slash,'misc',slash,'skewnormal_example',slash);

% handle missing files or load data
means_filepath = strcat(directory, 'skewnormal_example_means.mat');
variances_filepath = strcat(directory, 'skewnormal_example_variances.mat');
controls_filepath = strcat(directory, 'skewnormal_example_controls.mat');
error_message_base = 'The file can be generated by running the skewnormal_example.nb in Mathematica or downloaded from https://github.com/Risk-Sensitive-Reachability/IEEE-TCST-2021.';
if ~isfile(means_filepath)
    error(['Expected skewnormal_example_means.mat in misc/skewnormal_example. ', error_message_base]);
end
if ~isfile(variances_filepath)
    error(['Expected skewnormal_example_variances.mat in misc/skewnormal_example.', error_message_base]);
end
if ~isfile(controls_filepath)
    error(['Expected skewnormal_example_controls.mat in misc/skewnormal_example.', error_message_base]);
end
means = load('skewnormal_example_means.mat', 'Expression1').Expression1;
variances = load('skewnormal_example_variances.mat', 'Expression1').Expression1;
controls = load('skewnormal_example_controls.mat', 'Expression1').Expression1; 

%%  Part V: Plotting the u that Minimizes the Certainty Equivalent
%  
%   Suppose you want to find u to minimize 
%   
%       ce(u, gamma) = mean(phi(u,w)) + gamma * variance(phi(u,w))
%   
%   where gamma is a scalar that reflects your preferences in terms of 
%   the price you are willing to pay for a unit reduction in variance
%   
%   let's consider gamma in the range 0 to 5
%       0 => I only care about minimizing the mean, I am willing to pay 0 to reduce variance
%       5 => I care deeply about variance, I am willing to pay up to 5 units of mean to reduce 1 unit of variance
%       
gammas = linspace(0,5,500);          % draw 500 gammas linearly spaced from 0 to 5
ce = means + gammas .* variances;    % calculate ce for each gamma and u
                                     %   each column in ce corresponds to a gamma in 'gammas'
                                     %   each row in ce corresponds to a u in 'controls'

close all; 
figure('Renderer',  'painters', 'Position', [100 0 1750 400])
subplot(1,3,1);
hold on; 

% plot ce for first, last, and every 25th value of gamma
for gammaIndex = 1:length(gammas)
    
    isFirstGamma = gammaIndex == 1; 
    isLastGamma = gammaIndex == length(gammas); 
    isAMultipleOf25 = mod(gammaIndex, 25) == 0;
       
    if isFirstGamma || isLastGamma || isAMultipleOf25
        plot(controls, ce(:,gammaIndex), '-', 'LineWidth',2);
    end
   
end

% plot and optimal points for first, last, and every 25th value of gamma
for gammaIndex = 1:length(gammas)
    
    isFirstGamma = gammaIndex == 1; 
    isLastGamma = gammaIndex == length(gammas); 
    isAMultipleOf25 = mod(gammaIndex, 25) == 0;
       
    if isFirstGamma || isLastGamma || isAMultipleOf25
       [optimal_ce, optimal_u_index] = min(ce(:,gammaIndex));
       plot(controls(optimal_u_index), optimal_ce, 'o', 'MarkerFaceColor','k', ...
            'Color', 'None');
        
       if isFirstGamma
          text(...
              controls(optimal_u_index) + 0.01,...
              optimal_ce-0.4, strcat('$$\gamma =',{' '},mat2str(gammas(gammaIndex)), '$$'));
       end
       
       if isLastGamma
          text(...
              controls(optimal_u_index) - 0.03,...
              optimal_ce+0.6, strcat('$$\gamma =',{' '},mat2str(gammas(gammaIndex)), '$$'));
       end
    end
   
end


[optimal_ce, optimal_u_index] = min(ce);

% uncomment the line below to draw optimal curve connecting black dots
% plot(dense_controls(optimal_u_index),optimal_ce,'LineWidth',2,'Color','Black'); 

ylabelstring = 'ce[$$\phi(u, W),\gamma$$]';

% build the legend
h = zeros(1, 1);
h(1) = plot(NaN,NaN,'-','LineWidth', 2, 'Color', '#888888');
h(2) = plot(NaN,NaN,'o','LineWidth', 2, 'MarkerFaceColor', 'Black', 'Color', 'None');
legend(h, ylabelstring, 'ce[$$\phi(u^\ast,W),\gamma$$]', ...
    'FontSize', 12, 'Orientation', 'horizontal', 'Location', 'northwest');
legend boxoff; 

xlabel('u'); ylabel(ylabelstring); title('$$\gamma \in [0, 5]$$');
ylim([0, 16]); 

hold off; 

% create subplot for gamma = 0
subplot(1,3,2);
hold on;
plot(controls, ce(:,1), '-', 'LineWidth',2,'Color','#0071bd');
plot(controls(optimal_u_index(1)), optimal_ce(1), 'o', 'MarkerFaceColor','k', ...
            'Color', 'None');
xlabel('u'); ylabel(ylabelstring); title(strcat('$$\gamma$$ =',{' '},mat2str(gammas(1))));
hold off;

% create subplot for gamma = 5
subplot(1,3,3);
hold on;
plot(controls, ce(:,length(gammas)), '-', 'LineWidth',2,'Color','#a2142f');
plot(controls(optimal_u_index(length(gammas))), optimal_ce(length(gammas)), 'o', 'MarkerFaceColor','k', ...
            'Color', 'None');
        
xlabel('$u$'); ylabel(ylabelstring); title(strcat('$$\gamma$$ =',{' '},mat2str(gammas(length(gammas)))));
hold off; 
sgtitle(strcat(ylabelstring, {' '}, ' vs. u')); 

% save the image
output_filename = strcat(plot_directory, 'skewnormal_minimize_certainty_equivalent');
set(gcf,'Units','Inches'); 
pos = get(gcf, 'Position'); 
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,output_filename,'-dpdf','-r0')


%%  Part VI: Plotting the u that Minimizes CVaR
%
%   Suppose instead you want to find u to minimize cvar(phi(u,w), alpha)
%   
%   where alpha is a scalar that reflects your preferences in terms of 
%   what portion of the worst case outcomes you care about
%   
%   let's consider alpha in the range 0.05 to 1
%      
%       0.05  => I want to minimize the average cost of the worst 5% of outcomes (risk-averse)
%       1     => I want to minimize the average cost of all possible otucomes (risk-neutral)
%       
%   we can sample the pdf of phi(u, w) using Mathematica
%   
%   here we draw 1E5 samples for each u in (0, 0.25) by du = 0.001
%
%   umin = 0.00; umax = 0.25; du = 0.001; 
%   costDistributions = Table[
%       SeedRandom[0]; 
%       RandomVariate[
%           TransformedDistribution[u^2 + (W + u)^2, W \[Distributed] dist], 100000], 
%           {u, umin, umax, du}];
%
%   load the pre-computed data from Mathematica
hundredThousandSamples = nan(251, 1E5);
for i = 1:251
    hundredThousandSamples(i,:) = load(strcat('skewnormal_example_phi_1E5_samples_',mat2str(i),'.mat'), 'Expression1').Expression1;
end

% determine alpha values to evaluate
alphas = [1, 0.5, 0.25, 0.15, 0.1, 0.075, 0.05];
cvars = nan(length(controls), length(alphas)); 
vars = nan(length(controls), length(alphas)); 

close all; 
figure('Renderer',  'painters', 'Position', [100 0 1750 400])
subplot(1,3,1);
hold on; 

% plot cvar(phi(u,w), alpha) for each alpha in alphas
for aindex = 1:length(alphas)

    for uindex = 1:length(controls)
    
        alpha = alphas(aindex);  
        Z = hundredThousandSamples(uindex,:);
        vars(uindex, aindex) = quantile(Z, 1-alpha); 
        cvars(uindex, aindex) = estimate_CVaR_from_emperical_data(Z, alpha, vars(uindex, aindex)); 
        
    end

    plot(controls, cvars(:, aindex), '-', 'LineWidth', 2);
    hold on; 
end

% plot and optimal points for all alphas
u_offsets_for_labels = [0.005, 0.0025, -0.01, -0.01, -0.01, -0.01, -0.02]; 
for alphaIndex = 1:length(alphas)

   isLastAlpha = alphas(alphaIndex) == 0.05;
    
   [optimal_cvar, optimal_u_index] = min(cvars(:,alphaIndex));
   plot(controls(optimal_u_index), optimal_cvar, 'o', 'MarkerFaceColor','k', 'Color', 'None');

   text(...
       controls(optimal_u_index) + u_offsets_for_labels(alphaIndex),...
       optimal_cvar+0.25, strcat('$$\alpha =',{' '},mat2str(alphas(alphaIndex)), '$$'));
end

ylabelstring = 'CVaR[$$\phi(u,W),\alpha$$]';

% build the legend
h = zeros(1, 1);
h(1) = plot(NaN,NaN,'-','LineWidth', 2, 'Color', '#888888');
h(2) = plot(NaN,NaN,'o','LineWidth', 2, 'MarkerFaceColor', 'Black', 'Color', 'None');
legend(h, ylabelstring, 'CVaR[$$\phi(u^\ast,W),\alpha$$])]', ...
    'FontSize', 10, 'Orientation', 'horizontal', 'Location', 'northwest');
legend boxoff; 

hold off; 

xlabel('u'); ylabel(ylabelstring); title('$$\alpha$$ in [1, 0.05]');
ylim([0, 8]); 

hold off; 

[optimal_cvar, optimal_u_index] = min(cvars);

% create subplot for alpha = 1
subplot(1,3,2);
hold on;
plot(controls, cvars(:,1), '-', 'LineWidth',2,'Color','#0071bd');
plot(controls(optimal_u_index(1)), optimal_cvar(1), 'o', 'MarkerFaceColor','k', ...
            'Color', 'None');
xlabel('u'); ylabel(ylabelstring); title(strcat('$$\alpha =',{' '},mat2str(alphas(1)),'$$'));
hold off;

% create subplot for alpha = 0.05
subplot(1,3,3);
hold on;
plot(controls, cvars(:,length(alphas)), '-', 'LineWidth',2,'Color','#a2142f');
plot(controls(optimal_u_index(length(alphas))), optimal_cvar(length(alphas)), 'o', 'MarkerFaceColor','k', ...
            'Color', 'None');
        
xlabel('u'); ylabel(ylabelstring); title(strcat('$$\alpha =',{' '},mat2str(alphas(length(alphas))),'$$'));
hold off; 
sgtitle(strcat(ylabelstring, {' '}, ' vs. u')); 

% save the image
output_filename = strcat(plot_directory, 'skewnormal_minimize_cvar');
set(gcf,'Units','Inches'); 
pos = get(gcf, 'Position'); 
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,output_filename,'-dpdf','-r0')


%%  Part VII: Smaller Plots for CVaR and CE curves
%
%   This code is very similar to Part V and Part VII above, but only plots first subplot. 
%   see plot_figure_3 and plot_figure_4 for details
output_filename = strcat(plot_directory, 'skewnormal_ce_curves');
plot_figure_3(output_filename); 

output_filename = strcat(plot_directory, 'skewnormal_cvar_curves');
plot_figure_4(output_filename); 
