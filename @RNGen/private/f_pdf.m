function [x_pdf, y_pdf] = f_pdf(nVals, law, range, params)
    %F_PDF Returns nVals probabilities y_pdf at x_pdf according to law inside range for given params

    x_pdf = linspace(range(1), range(2), nVals); % sampling points in row vector
    switch law % pick pdf (see >>edit pdf.m)
        case "uniform" % uniform distribution
            y_pdf = unifpdf(x_pdf, params.uniform_a, params.uniform_b)/nVals; % normalize
        case "normal" % normal distribution
            y_pdf = normpdf(x_pdf, params.normal_mu, params.normal_sigma);
        case "gamma" % gamma distribution
            y_pdf = gampdf(x_pdf, params.gamma_a, params.gamma_b);
        case "logn" % log-normal distribution
            y_pdf = lognpdf(x_pdf, params.logn_mu, params.logn_sigma);
        otherwise
            error('Unsupported random number law encountered.');
    end

end
