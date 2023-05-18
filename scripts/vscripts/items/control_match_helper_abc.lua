require('player_power')

function modifier_item_control_match_helper_abc_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_control_match_helper_abc_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local item_control_match_helper_a_precent_base = ability:GetSpecialValueFor("item_control_match_helper_a_precent_base")
    local item_control_match_helper_b_precent_base = ability:GetSpecialValueFor("item_control_match_helper_b_precent_base")
    local item_control_match_helper_c_precent_base = ability:GetSpecialValueFor("item_control_match_helper_c_precent_base")


    setPlayerPower(playerID, "player_control_match_helper_a_precent_base", flag, item_control_match_helper_a_precent_base)
    setPlayerPower(playerID, "player_control_match_helper_b_precent_base", flag, item_control_match_helper_b_precent_base)
    setPlayerPower(playerID, "player_control_match_helper_c_precent_base", flag, item_control_match_helper_c_precent_base)

end