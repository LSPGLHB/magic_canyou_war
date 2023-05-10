require('player_power')

function modifier_item_damage_b_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_damage_b_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_damage_b = ability:GetSpecialValueFor("item_damage_b")
    local item_damage_b_precent_base = ability:GetSpecialValueFor("item_damage_b_precent_base")

    setPlayerPower(playerID, "player_damage_b", flag, item_damage_b)
    setPlayerPower(playerID, "player_damage_b_precent_base", flag, item_damage_b_precent_base)

end