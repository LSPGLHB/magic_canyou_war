require('player_power')

function modifier_item_ability_speed_c_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_ability_speed_c_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_ability_speed_c = ability:GetSpecialValueFor("item_ability_speed_c")
    local item_ability_speed_c_precent_base = ability:GetSpecialValueFor("item_ability_speed_c_precent_base")

    setPlayerPower(playerID, "player_ability_speed_c", flag, item_ability_speed_c)
    setPlayerPower(playerID, "player_ability_speed_c_precent_base", flag, item_ability_speed_c_precent_base)



end