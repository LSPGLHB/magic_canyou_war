require('player_power')

function modifier_item_control_a_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_control_a_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base")
    local item_damage = ability:GetSpecialValueFor("item_damage")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")
    local item_speed = ability:GetSpecialValueFor("item_speed")

    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_damage_a", flag, item_damage)
    setPlayerPower(playerID, "player_damage_b", flag, item_damage)
    setPlayerPower(playerID, "player_damage_c", flag, item_damage)
    setPlayerPower(playerID, "player_damage_d", flag, item_damage)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)

end