function [x_rnd] = f_rnd(nVals, law, range, params)
    %F_RND Returns nVals values x_rnd drawn from law inside range for given params

    x_rnd = zeros(1, nVals); % initialize column vector
    needUpdate = true(1, nVals); % flags
    while any(needUpdate) % until all are in range
        tmp_size = [1, sum(needUpdate)]; % size-array with n rows for number of invalid entries
        switch law % pick rnd (see >>edit random.m)
            case "uniform" % uniform distribution
                tmp_y = unifrnd(params.uniform_a, params.uniform_b, tmp_size);
            case "normal" % normal distribution
                tmp_y = normrnd(params.normal_mu, params.normal_sigma, tmp_size);
            case "gamma" % gamma distribution
                tmp_y = gamrnd(params.gamma_a, params.gamma_b, tmp_size);
            case "logn" % log-normal distribution
                tmp_y = lognrnd(params.logn_mu, params.logn_sigma, tmp_size);
            otherwise
                error('Unsupported random number law encountered.');
        end
        x_rnd(needUpdate) = tmp_y; % update
        needUpdate = x_rnd < range(1) | range(2) < x_rnd; % probe range
    end

end
