require('myMaths')
function openUIMagicList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIMagicListPanelBox","file://{resources}/layout/custom_game/UI_magic_list.xml",nil)
end

function closeUIMagicList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMagicListPanelBox")
end