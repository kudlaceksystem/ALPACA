function [subjNm, anStartDt, anEndDt, chName] = dbfGetSubjInfo(stg, lblpn, subjNmOrig, varargin)
    lll = load(lblpn{1}, 'sigInfo', 'lblDef', 'lblSet');
    lll.sigInfo = dt.tblSetTimeZone(lll.sigInfo, stg.recTimeZoneStr);
    lll.sigInfo = dt.tblSetTimeZone(lll.sigInfo, "UTC");
    % There can be multiple subjects in one lbl3 file. Keep only channels containing the data on the subject.
    ss = strsplit(subjNmOrig, 'ET'); % ET stands for ear tag. Sometimes it is included in the subject name
    whichChannelsLbl = find(contains(lll.sigInfo.Subject, ss{end}));
    % sigInfo = lll.sigInfo(whichChannelsLbl, :);
    chName = lll.sigInfo.ChName;

    % % % % % % % % % % lblSet = lblSet(ismember(lblSet.Channel, whichChannelsLbl), :);
    % Check that all rows belong to the same subject
    subjNm = lll.sigInfo.Subject(1);
    if ~all(lll.sigInfo.Subject == subjNm)
        disp(lll.sigInfo)
        error('_jk Multiple subjects in label file.')
    end
    anStartDt = min(lll.sigInfo.SigStart); % Analysis start determined by label files
    lastLbl = load(lblpn{end}, 'sigInfo');
    lastLbl.sigInfo = dt.tblSetTimeZone(lastLbl.sigInfo, stg.recTimeZoneStr);
    lastLbl.sigInfo = dt.tblSetTimeZone(lastLbl.sigInfo, "UTC");
    lastSigInfo = lastLbl.sigInfo(whichChannelsLbl, :);
    anEndDt = max(lastSigInfo.SigEnd); % Analysis end determined by signal files
    if numel(varargin) == 0
        return
    else
        snlpn = varargin{1};
    end
    % Now the same with signal data (e.g. markers of critical slowing)
    load(snlpn{1}, 'sigTbl')
    whichChannelsSnl = contains(sigTbl.Subject, ss{end});
    sigTbl = sigTbl(whichChannelsSnl, :);
    subjNm = sigTbl.Subject(1);
    if ~all(sigTbl.Subject == subjNm)
        error('_jk Multiple subjects in signal file.')
    end
    % % % % % % % % % % % anStartDt = min(sigInfo.SigStart); % Analysis start determined by label files
    anStartDtSig = min(sigTbl.SigStart); % Analysis start determined by signal files
    % % % % % % % % % % % % lastLbl = load(lblpn{end});
    lastSigInfo = lastLbl.sigInfo(whichChannelsLbl, :);
    if any(lll.sigInfo.Subject ~= lastSigInfo.Subject)
        error('_jk Last label file has diffent channels than the first file.')
    end
    lastSnl = load(snlpn{end});
    lastSigTbl = lastSnl.sigTbl(whichChannelsSnl, :);
    if any(sigTbl.Subject ~= lastSigTbl.Subject)
        error('_jk Last signal file has diffent channels than the first file.')
    end
    % % % % % % % % % % anEndDt = max(lastSigInfo.SigEnd); % Analysis end determined by signal files
    anEndDtSig = max(lastSigTbl.SigEnd); % Analysis end determined by label files
    if abs(anEndDt - anEndDtSig) > seconds(1) || abs(anStartDt - anStartDtSig) > seconds(1) % If they differ by more than a second
        disp('Analysis start difference:')
        disp((anStartDt - anStartDtSig)*3600*24)
        disp('Analysis end difference:')
        disp((anEndDt - anEndDtSig)*3600*24)
        error('_jk Label data and signal data have different time extent')
    end
end
