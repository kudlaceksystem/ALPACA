function ll = dbfChannels(ll, subjNmOrig, channelNames)
    % Keep only channels belonging to this animal
    chToKeep = find(ll.sigInfo.Subject == string(subjNmOrig));
    ll.sigInfo = ll.sigInfo(chToKeep, :);
    ll.lblSet = ll.lblSet(ismember(ll.lblSet.Channel, chToKeep), :);
    % Check channel names
    if numel(ll.sigInfo.ChName) ~= numel(channelNames)
        error('_jk getData: Number of channels inconsistent.')
    end
    if ~all(ll.sigInfo.ChName == channelNames)
        error('_jk getData: Channel order inconsistent.')
    end
end