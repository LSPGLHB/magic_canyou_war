require('player_power')

function modifier_item_damage_c_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_damage_c_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_damage_c_percent_base = ability:GetSpecialValueFor("item_damage_c_percent_base")
    local item_health = ability:GetSpecialValueFor("item_health")
    
    local item_ability_speed = ability:GetSpecialValueFor("item_ability_speed")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")

    
    
    setPlayerPower(playerID, "player_damage_c_percent_base", flag, item_damage_c_percent_base)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_ability_speed", flag, item_ability_speed)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)


    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")

end