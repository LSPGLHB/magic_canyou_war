require('player_power')

function modifier_public_range_c_on_created(keys)
    print("modifier_public_range_c_on_created")
    refreshPublicRangeCPowerUpBuff(keys,true)
end

function modifier_public_range_c_on_destroy(keys)
    print("modifier_public_range_c_on_destroy")
    refreshPublicRangeCPowerUpBuff(keys,false)

end

function refreshPublicRangeCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local public_range_c_precent_final = ability:GetSpecialValueFor( "public_range_c_precent_final")

    setPlayerPower(playerID, "player_range_c_precent_final", flag, public_range_c_precent_final)
end



function modifier_public_damage_c_on_created(keys)
    print("modifier_public_damage_c_on_created")
    refreshPublicDamageCPowerUpBuff(keys,true)
end

function modifier_public_damage_c_on_destroy(keys)
    print("modifier_public_damage_c_on_destroy")
    refreshPublicDamageCPowerUpBuff(keys,false)

end

function refreshPublicDamageCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local public_damage_c_precent_final = ability:GetSpecialValueFor( "public_damage_c_precent_final")

    setPlayerPower(playerID, "player_damage_c_precent_final", flag, public_damage_c_precent_final)
end



function modifier_public_ability_speed_c_on_created(keys)
    print("modifier_public_ability_speed_c_on_created")
    refreshPublicDamageCPowerUpBuff(keys,true)
end

function modifier_public_ability_speed_c_on_destroy(keys)
    print("modifier_public_ability_speed_c_on_destroy")
    refreshPublicDamageCPowerUpBuff(keys,false)

end

function refreshPublicAbilitySpeedCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local public_damage_c_precent_final = ability:GetSpecialValueFor( "public_ability_speed_c_precent_final")

    setPlayerPower(playerID, "player_ability_speed_c_precent_final", flag, public_ability_speed_c_precent_final)
end



function modifier_public_control_c_on_created(keys)
    print("modifier_public_control_c_on_created")
    refreshPublicDamageCPowerUpBuff(keys,true)
end

function modifier_public_control_c_on_destroy(keys)
    print("modifier_public_control_c_on_destroy")
    refreshPublicDamageCPowerUpBuff(keys,false)

end

function refreshPublicAbilitySpeedCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local public_damage_c_precent_final = ability:GetSpecialValueFor( "public_control_c_precent_final")

    setPlayerPower(playerID, "player_control_c_precent_final", flag, public_control_c_precent_final)
end