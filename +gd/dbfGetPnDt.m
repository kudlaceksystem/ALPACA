function [pn, Dt] = dbfGetPnDt(stg, p)
    % Get file path, name, start date in datetime and datenum
    d = dir([p, '\*.mat']);
    n = {d.name}';
    pn = fullfile(p, n);
    Dt = cellfun(@(x) datetime(regexp(x, '\d\d\d\d\d\d_\d\d\d\d\d\d', 'match'), 'InputFormat', 'yyMMdd_HHmmss'), n, 'UniformOutput', true);
    Dt.TimeZone = stg.recTimeZoneStr;
    
    % Deal with the files happening during transition from the summer daylight saving time to winter time.
    % !!! It only works if maximum of one such transition happens in the subject !!!
    whichAreAmbiguous = [];
    for kdt = 1 : numel(Dt)
        if dt.dtIsAmbiguous(Dt(kdt))
            whichAreAmbiguous = [whichAreAmbiguous, kdt]; %#ok<AGROW>
        end
    end
    if ~isempty(whichAreAmbiguous)
        ambDt = Dt(whichAreAmbiguous);
        dAmbDt = diff(ambDt);
        standardFileInterval = Dt(whichAreAmbiguous(1)) - Dt(whichAreAmbiguous(1) - 1);
        lastBeforeTimeChange = find(dAmbDt < 0.5*standardFileInterval); % Last one before the time change
        whichToAdjust = whichAreAmbiguous(1) : whichAreAmbiguous(1) + lastBeforeTimeChange - 1;
    else
        whichToAdjust = [];
    end
    Dt.TimeZone = "UTC";
    Dt(whichToAdjust) = Dt(whichToAdjust) - hours(1);

    if ~all(diff(Dt) > 0)
        warning('_jk gd.dbfGetPnDt File datetimes are not strictly increasing.');
        pause
    end
end
