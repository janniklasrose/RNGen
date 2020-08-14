function [vals] = generate(this, nVals, CurrentAxis)
%GENERATE Generate random values and plot their distribution
%
%   Syntax:
%       [vals] = GENERATE(nVals)
%       [vals] = GENERATE(nVals, CurrentAxis)
%   where
%       nVals       - number of values to be generated
%       CurrentAxis - optional axis handle (uses current axis if not specified)
%       vals        - row vector of size [1, nVals] containing the random values
%
% See also GENERATOR, DRAW

%%% checks
% number
validateattributes(nVals, "numeric", ["scalar", "integer", "nonnegative", "finite"]); % allow 0
% optional axis
switch nargin()
    case 2
        ax = gca(); % get current axis
    case 3
        validateattributes(CurrentAxis, "matlab.graphics.axis.Axes", "scalar");
        ax = CurrentAxis;
    otherwise
        narginchk(2, 3);
end

%%% statistics
% draw random numbers
x_rnd = this.draw(nVals, "rnd");
vals  = x_rnd; 
% draw pdf
[x_pdf, y_pdf] = this.draw(1000, "pdf"); % 1000 points should give a good plot
% histogram
binEdges = linspace(this.range(1), this.range(2), 21); % 20 bins should look ok
[binCounts, ~] = histcounts(x_rnd, binEdges, "Normalization", "pdf");

%%% visualisation
% show statistics
wasHold = ishold(ax); % current state
if nVals > 0 % at least one sample drawn
    histogram(ax, "BinEdges", binEdges, "BinCounts", binCounts, "FaceColor", 'g'); % hist
    hold(ax, "on"); % enable hold
end
plot(ax, x_pdf, y_pdf, 'r', "LineWidth", 1); % pdf
axis(ax, [this.range(1), this.range(2), 0, +Inf()]); % flexible y-max
if ~wasHold
    hold(ax, "off"); % restore previous state
end

end
