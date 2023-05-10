require('player_power')

function modifier_item_damage_a_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_damage_a_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_damage_a = ability:GetSpecialValueFor("item_damage_a")
    local item_damage_a_precent_base = ability:GetSpecialValueFor("item_damage_a_precent_base")

    setPlayerPower(playerID, "player_damage_a", flag, item_damage_a)
    setPlayerPower(playerID, "player_damage_a_precent_base", flag, item_damage_a_precent_base)

end