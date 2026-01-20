function channelNames = dbfGetChannelNames(lblpn, subjNmOrig)
    ll = load(lblpn, 'sigInfo');
    % Keep only channels belonging to this animal
    chToKeep = find(ll.sigInfo.Subject == string(subjNmOrig));
    ll.sigInfo = ll.sigInfo(chToKeep, :);
    channelNames = ll.sigInfo.ChName;
end