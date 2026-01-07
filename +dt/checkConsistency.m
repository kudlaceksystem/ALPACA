function isConsistentTF = checkConsistency(lblpn, klbl, ll)
    warning('on', 'all')
    % % % % % % % % 
    % % % % % % % % % If ll.sigInfo is empty there is nothing to check
    % % % % % % % % if isempty(ll.sigInfo)
    % % % % % % % %     isConsistentTF = true;
    % % % % % % % %     return
    % % % % % % % % end
    
    % Check if sigInfo.FileName corresponds to file name
    fndattimStr = regexp(lblpn{klbl}, '\d\d\d\d\d\d_\d\d\d\d\d\d', 'match');
    filenameDt = datetime(fndattimStr{1}, 'InputFormat', 'yyMMdd_HHmmss');
    fcdattimStr = regexp(ll.sigInfo.FileName, '\d\d\d\d\d\d_\d\d\d\d\d\d', 'match');
    filecontDt = datetime(fcdattimStr{1}, 'InputFormat', 'yyMMdd_HHmmss');
    filenameConsWithFilen = filenameDt == filecontDt;
    if ~filenameConsWithFilen
        disp('_jk checkConsistency:')
        disp(klbl)
        disp(lblpn{klbl})
        disp(ll.sigInfo)
        warning('_jk File name and file contents do not correspond in terms of the date and time.')
    end
    
    % Check if SigStart corresponds to file name
    fndattimStr = regexp(lblpn{klbl}, '\d\d\d\d\d\d_\d\d\d\d\d\d', 'match');
    filenameDt = datetime(fndattimStr{1}, 'InputFormat', 'yyMMdd_HHmmss');
    filecontDt = ll.sigInfo.SigStart;
    sigStartConsWithFilen = all(filenameDt == filecontDt);
    if ~sigStartConsWithFilen
        disp(klbl)
        disp(lblpn{klbl})
        disp(ll.sigInfo)
        warning('_jk SigStart does not correspond to file name.')
    end
    isConsistentTF = filenameConsWithFilen && sigStartConsWithFilen;
    if ~isConsistentTF
        pause
    end
end