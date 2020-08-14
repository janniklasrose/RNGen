classdef RNGen < handle
    %RNGEN Class that handles random number generation
    %
    %   Objects of this class hold all properties necessary to generate random numbers, which are
    %   set during construction. The methods are then used to generate a variable number of random
    %   numbers, either via random number generation or probability density function.
    %
    %   DEPENDENCIES: This class requires the MATLAB Statistics and Machine Learning Toolbox.
    %
    % See also RNGEN/RNGEN, VALID_LAWS

    %%% constants
    properties(Constant=true, GetAccess=public)

        %VALID_LAWS Laws that are supported by this class
        %
        %   The parameters required for generation differ for each law. The currently supported
        %   laws are ["uniform", "normal", "gamma", "logn"].
        %
        % See also RNGEN
        VALID_LAWS = ["uniform", "normal", "gamma", "logn"];

    end

    %%% properties
    properties(SetAccess=private, GetAccess=public)

        %LAW Random number law
        %
        %   Should be specified in a row vector of char's such as in the example below.
        %
        %   Example:
        %       LAW = 'normal'; range = [-0.4, +5.9]; param = [+3.1, 0.2];
        %
        % See also RNGEN, VALID_LAWS
        law(1,1) string {mustBeValidLaw} = ""

        %RANGE Range of drawn random numbers
        %
        %   Should be specified in a numeric 2-element row vector such as in the example below.
        %
        %   Example:
        %       law = 'normal'; RANGE = [-0.4, +5.9]; param = [+3.1, 0.2];
        %
        % See also RNGEN
        range(1,2) {mustBeNondecreasing, mustBeNonNan} = [-inf, +inf]

        %PARAM param = parameters, e.g. [mu, sigma]
        %
        %   Should be specified in a numeric row vector such as in the example below.
        %
        %   Example:
        %       law = 'normal'; range = [-0.4, +5.9]; PARAM = [+3.1, 0.2];
        %
        % See also RNGEN
        param(1,:)

    end

    %%% constructor
    methods(Access=public)
        function [this] = RNGen(law, range, param)
            %RNGEN.RNGEN Constructor method of class RNGEN
            %
            %   Syntax:
            %       [object] = RNGEN(law, range, param)
            %   with arguments:
            %       <a href="matlab: help RNGen.law">law</a>
            %       <a href="matlab: help RNGen.range">range</a>
            %       <a href="matlab: help RNGen.param">param</a>
            %
            % See also RNGEN, VALID_LAWS, LAW, RANGE, PARAM

            %%% checks
            % argument count
            if nargin() == 0
                return; % prevent recursion
            end
            %%% assign
            narginchk(2, 3);
            this = RNGen();
            % first these two, their validators take care of checking the input
            this.law = law;
            this.range = range; % can be scalar x, sets range to [x, x]
            % lastly, param, whos validation is more complex
            switch nargin()
                case 2
                    if ~strcmp(law, "uniform")
                        error("Law ""%s"" requires additional parameters.", law);
                    end
                    param = reshape([], [1, 0]);
                case 3
                    if strcmp(law, "uniform")
                        warning("Law ""%s"" does not support additional parameters.", law);
                        param = reshape([], [1, 0]);
                    else
                        validateattributes(param, "numeric", {"size", [1, 2], "finite"}, 3);
                        % negative mean breaks gamma and logn
                        if param(1)<=0 && ( strcmp(law, "gamma") || strcmp(law, "logn") )
                            error("Invalid negative value in param(1) for law ""%s"".", law);
                        end
                        % negative variance breaks normal and gamma and logn
                        if param(2)<0 && any(strcmp(law, ["normal", "gamma", "logn"]))
                            error("Invalid negative value in param(2) for law ""%s"".", law);
                        end
                    end
            end
            this.param = param; % finally store it

        end
    end

    %%% main methods
    methods(Access=public)
        [vals] = generate(this, nVals, CurrentAxis)
        [yVals, xVals] = draw(this, nVals, rnd_or_pdf, stream)
    end

end

%%% validators
function mustBeValidLaw(law)
    if law.strlength == 0
        return
    end
    mustBeMember(law, RNGen.VALID_LAWS)
end

function mustBeNondecreasing(range)
    if isnan(range)
        return
    end
    validateattributes(range, {'numeric'}, {'nondecreasing'});
end
