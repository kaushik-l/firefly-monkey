function prs=getfileLocation(monk_id,session_id)

monkeyInfoFile_joysticktask;
if monk_id == 0 & session_id == 0
    monkeyInfo;
    for i = 1:length(monkeyInfo)
        prs.filepath_behv{i} = ['W:\Data\Monkey_discovery\' monkeyInfo(i).folder '\behavioural data\'];
    end
else
    monkeyInfo = monkeyInfo([monkeyInfo.session_id]==session_id & [monkeyInfo.monk_id]==monk_id);
    prs.filepath_behv{1} = ['W:\Data\Monkey2_newzdrive\' monkeyInfo.folder '\behavioural data\'];
end

end