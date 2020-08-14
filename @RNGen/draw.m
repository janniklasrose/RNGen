function [xVals, yVals] = draw(this, nVals, rnd_or_pdf, stream)
%DRAW Draw random values from random number generator or sample from probability density function
%
%   Syntax:
%       xVals = DRAW(nVals)
%       xVals = DRAW(nVals, rnd_or_pdf)
%       [xVals, yVals] = DRAW(nVals, 'pdf')
%   where
%       nVals      - number of values to be drawn
%       rnd_or_pdf - 'rnd' or 'pdf' specifying type of draw
%       xVals      - row vector of size [1, nVals] containing the x-values (random values)
%       yVals      - row vector of size [1, nVals] containing the y-values (probabilities)
%
% See also GENERATOR, GENERATE

%%% checks
% number
validateattributes(nVals, "numeric", ["scalar", "integer", "nonnegative", "finite"]); % allow 0
% optional args
narginchk(2, 4);
if nargin() < 3
    rnd_or_pdf = "rnd"; % assume random draws
else
    validatestring(rnd_or_pdf, ["rnd", "pdf"]);
end
if nargin() < 4
    useCustomStream = false; % use existing global stream
else
    validateattributes(stream, "RandStream", "scalar");
    useCustomStream = true;
end

%%% parameters
switch this.law
    case "uniform"
        params.uniform_a    = this.range(1);
        params.uniform_b    = this.range(2);
    case "normal"
        params.normal_mu    = this.param(1);
        params.normal_sigma = sqrt(this.param(2));
    case "gamma"
        params.gamma_a      = this.param(1)^2 / this.param(2);
        params.gamma_b      = this.param(2) / this.param(1);
    case "logn"
        params.logn_mu      = log(this.param(1))-1/2*log(1+this.param(2)/this.param(1)^2);
        params.logn_sigma   = sqrt(log(1+this.param(2)/this.param(1)^2));
end

%%% draw
if useCustomStream % use desired stream as global (complex random functions don't support streams)
    oldGlobalStream = RandStream.getGlobalStream; % store old global stream
    oldRandomState = oldGlobalStream.State; % store old state
    RandStream.setGlobalStream(stream);
end
switch rnd_or_pdf
    case "rnd"
        if nargout() == 2
            error("A second argument can only be returned for ""pdf"", not ""rnd"".");
        end
        xVals = f_rnd(nVals, this.law, this.range, params); % call private function
    case "pdf"
        [xVals, yVals] = f_pdf(nVals, this.law, this.range, params); % call private function
end
if useCustomStream % use desired stream as global (complex random functions don't support streams)
    oldGlobalStream.State = oldRandomState; % restore old state
    RandStream.setGlobalStream(oldGlobalStream); % restore old global stream
end

%%% return
return;

end
