require('player_power')

function modifier_item_range_a_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_range_a_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_range_a = ability:GetSpecialValueFor("item_range_a")
    local item_range_a_precent_base = ability:GetSpecialValueFor("item_range_a_precent_base")
    local item_radius_a_precent_base = ability:GetSpecialValueFor("item_radius_a_precent_base")

    setPlayerPower(playerID, "player_range_a", flag, item_range_a)
    setPlayerPower(playerID, "player_range_a_precent_base", flag, item_range_a_precent_base)
    setPlayerPower(playerID, "player_radius_a_precent_base", flag, item_radius_c_precent_base)


end