function figBinCount(stg, h, d, subjInfo, ds, dp, ~)
    histEdges = 0 : 30;
    discreteHistogramTF = true;
    nm = d.Name;
    evnm = d.EventName; % Name of the event to analyze
    vanm = d.EventValidSrc; % Name of the dp field to get the data on validity of the source data
    binlenDu = days(3); % Length of couning bin
    binshiftDu = days(1);
    first = ds.(evnm).OnsDt(1);
    last = ds.(evnm).OnsDt(end);
    numbin = floor((last - first - binlenDu)/binshiftDu) + 1;
    % Initialize the bin edges for the histogram
    binDt = first : binshiftDu : last;
    binCounts = NaN(numbin, 1);
    for kb = 1 : numbin
        dpTax = dp.(vanm).tax; % dpTax contains ends of the dp bins
        dpBinlenDu = mode(diff(dpTax)); % Maybe in future we may allow overlapping windows in dp and this line will need to be adapted.
        dpBinlenS = seconds(dpBinlenDu);
        minRequiredValidS = 0.8*dpBinlenS; % 20% missing is tolerated
        validSt = find(dpTax > binDt(kb), 1, "first"); % Find the first dp bin which has the end later than counting bin starts
        validEn = find(dpTax - dpBinlenDu < binDt(kb+1), 1, "last"); % Find the last dp bin which has the start before the conting bin ends
        valid = dp.(vanm).ValidS(validSt : validEn, :);
        if any(valid > dpBinlenS*1.01, "all") % Just check that the validS is shorter than the bin length (otherwise there is a bug somewhere in getData)
            disp('valid = ')
            disp(valid)
            disp('dpBinelnS = ')
            disp(dpBinlenS)
            warning('_jk fig.figBinCount More valid signal than bin length.')
            pause
        end
        valid = ~all(isnan(valid) | valid <= minRequiredValidS, 2);
        if all(valid)
            binCounts(kb, :) = sum(ds.(evnm).OnsDt >= binDt(kb) & ds.(evnm).OnsDt < binDt(kb+1));
        else
            binCounts(kb, :) = NaN;
        end
    end

    % Stats
    numbins = numel(binCounts);
    numev = sum(binCounts, 1, "omitmissing");
    
    % Compute histogram
    hc = histcounts(binCounts, histEdges);
    hcNorm = hc/numev;
    
    % Plot figure
    figure(h.f.(nm))
    [spx, spy, spWi, spHe, ~, numc] = fig.getSubplotXYWH(stg, h, d, stg.margGlob, stg.marg);
    h.f.(nm).Units = "centimeters";
    h.a.(nm)(subjInfo.ksubj, 1) = axes("Units", "centimeters", "Position", ...
        [spx(mod(subjInfo.ksubj - 1, numc) + 1), spy(ceil(subjInfo.ksubj/numc)), spWi, spHe], "NextPlot", "add");
    if discreteHistogramTF
        x = histEdges(1 : end -1);
        y = hcNorm;
        h.p.(nm)(subjInfo.ksubj, 1) = stem(x, y, 'Color', stg.subjColor(subjInfo.ksubj, :), 'LineWidth', 1);
    else
        x = histEdges; %#ok<UNRCH> % X data common for polynomial fitting and plotting
        x = repelem(x, 3);
        x = x(2 : end-1);
        y = NaN(size(x));
        y(1 : 3 : end) = 0;
        y(2 : 3 : end) = hcNorm;
        y(3 : 3 : end) = hcNorm;
        facecolor = 1 - 0.2*(1 - stg.subjColor(subjInfo.ksubj, :));
        h.p.(nm)(subjInfo.ksubj, 1) = patch(x, y, facecolor, 'LineWidth', 0.5, 'EdgeColor', 'k');
    end
    clear x y
end