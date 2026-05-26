function [vals] = generate(this, nVals, nPdf, CurrentAxis)
%GENERATE Generate random values and plot their distribution
%
%   Syntax:
%       [vals] = GENERATE(nVals)
%       [vals] = GENERATE(nVals, nPdf)
%       [vals] = GENERATE(nVals, nPdf, CurrentAxis)
%   where
%       nVals       - number of values to be generated
%       nPdf        - optional number of points used to draw the pdf curve
%       CurrentAxis - optional axis handle (uses current axis if not specified)
%       vals        - row vector of size [1, nVals] containing the random values
%
% See also GENERATOR, DRAW

%%% checks
% number
validateattributes(nVals, "numeric", ["scalar", "integer", "nonnegative", "finite"]); % allow 0
% optional args
nPdfDefault = 1000;
switch nargin()
    case 2
        ax = gca(); % get current axis
        nPdf = nPdfDefault;
    case 3
        validateattributes(nPdf, "numeric", ["scalar", "integer", "finite", "positive"]);
        ax = gca(); % get current axis
    case 4
        validateattributes(nPdf, "numeric", ["scalar", "integer", "finite", "positive"]);
        validateattributes(CurrentAxis, "matlab.graphics.axis.Axes", "scalar");
        ax = CurrentAxis;
    otherwise
        narginchk(2, 4);
end

%%% statistics
% draw random numbers
x_rnd = this.draw(nVals, "rnd");
vals  = x_rnd; 
% draw pdf
[x_pdf, y_pdf] = this.draw(nPdf, "pdf");
pdfMass = trapz(x_pdf, y_pdf);
if isfinite(pdfMass) && pdfMass > 0
    y_pdf = y_pdf / pdfMass; % match the range-truncated random draws
end
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
