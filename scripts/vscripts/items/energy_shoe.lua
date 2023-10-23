require('player_power')

function modifier_item_energy_shoe_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_energy_shoe_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local duration_speed_precent_final = ability:GetSpecialValueFor( "duration_speed_precent_final") 
    local item_speed_duration = ability:GetSpecialValueFor( "item_speed_duration") 
--[[
    setPlayerPower(playerID, "duration_speed_precent_final", flag, duration_speed_precent_final)
    setPlayerPower(playerID, "player_speed_duration", flag, item_speed_duration)

    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
]]
end