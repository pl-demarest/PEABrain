function scatterDistribution1D(currentData,data,offsetAmount,alpha,colors)
%use this function to visualize a dataset "data" broken down into subsets
%"currentData in a single dimension.

%this function works for visualizing sub-components within a dataset, and
%generates a histogram-like distribution figure.

%call this function in a for loop

y = zeros(size(currentData));
if length(currentData) == 1
    % For a single data point, create a narrow density surrounding that point
    xi = linspace(currentData - 0.5, currentData + 0.5, 100);
    f1 = exp(-(xi - currentData).^2 / (2*0.1^2));
else
[f1,xi] = ksdensity(currentData);
end

f = (f1- min(f1)) / ( max(f1) - min(f1) );
histogramOffset = f + offsetAmount;

% Plotting

line = plot([min(data)-1, max(data)+1], [0, 0], 'k'); % number line
hold on


points = scatter(currentData, y, 40, 'o', 'filled','MarkerEdgeColor','none','MarkerFaceColor',colors,'YJitter','density','YJitterWidth',0.3); % plot data with random offset
hold on;

% Create offset line y-values
offsetY = ones(1,length(histogramOffset)) * offsetAmount;

% Fill the area between histogram and offset line

fillAreaX = [xi, fliplr(xi)];  % Go forward in x, then reverse back
fillAreaY = [histogramOffset, fliplr(offsetY)];  % Upper boundary first, then reverse back along lower boundary
fill(fillAreaX, fillAreaY, colors, 'FaceAlpha', alpha, 'EdgeColor', 'none');



end

