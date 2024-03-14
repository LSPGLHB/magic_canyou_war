require('player_power')
--目前铭文全部是技能效果相关，所以只需保存数值即可
--c级技能分界线
function modifier_talent_range_c_on_created(keys)
    print("modifier_talent_range_c_on_created")
    refreshPublicRangeCPowerUpBuff(keys,true)
end

function modifier_talent_range_c_on_destroy(keys)
    print("modifier_talent_range_c_on_destroy")
    refreshPublicRangeCPowerUpBuff(keys,false)

end

function refreshPublicRangeCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_range_percent_final = ability:GetSpecialValueFor( "talent_range_percent_final")

    setPlayerPower(playerID, "talent_range_percent_final", flag, talent_range_percent_final)

end



function modifier_talent_damage_c_on_created(keys)
    print("modifier_talent_damage_c_on_created")
    refreshPublicDamageCPowerUpBuff(keys,true)
end

function modifier_talent_damage_c_on_destroy(keys)
    print("modifier_talent_damage_c_on_destroy")
    refreshPublicDamageCPowerUpBuff(keys,false)

end

function refreshPublicDamageCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_percent_final = ability:GetSpecialValueFor( "talent_damage_percent_final")

    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, talent_damage_percent_final)
end



function modifier_talent_ability_speed_c_on_created(keys)
    print("modifier_talent_ability_speed_c_on_created")
    refreshPublicAbilitySpeedCPowerUpBuff(keys,true)
end

function modifier_talent_ability_speed_c_on_destroy(keys)
    print("modifier_talent_ability_speed_c_on_destroy")
    refreshPublicAbilitySpeedCPowerUpBuff(keys,false)

end

function refreshPublicAbilitySpeedCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_ability_speed_percent_final = ability:GetSpecialValueFor( "talent_ability_speed_percent_final")

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, talent_ability_speed_percent_final)
end



function modifier_talent_control_c_on_created(keys)
    print("modifier_talent_control_c_on_created")
    refreshPublicControlCPowerUpBuff(keys,true)
end

function modifier_talent_control_c_on_destroy(keys)
    print("modifier_talent_control_c_on_destroy")
    refreshPublicControlCPowerUpBuff(keys,false)

end

function refreshPublicControlCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_control_percent_final = ability:GetSpecialValueFor("talent_control_percent_final")

    setPlayerPower(playerID, "talent_control_percent_final", flag, talent_control_percent_final)
end


function modifier_talent_damage_match_helper_c_on_created(keys)
    print("modifier_talent_damage_match_helper_c_on_created")
    refreshPublicDamageMatchHelperCPowerUpBuff(keys,true)
end

function modifier_talent_damage_match_helper_c_on_destroy(keys)
    print("modifier_talent_damage_match_helper_c_on_destroy")
    refreshPublicDamageMatchHelperCPowerUpBuff(keys,false)

end

function refreshPublicDamageMatchHelperCPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_match_helper_percent_final = ability:GetSpecialValueFor( "talent_damage_match_helper_percent_final")

    setPlayerPower(playerID, "talent_damage_match_helper_percent_final", flag, talent_damage_match_helper_percent_final)
end


--b级技能分界线
function modifier_talent_range_b_on_created(keys)
    print("modifier_talent_range_b_on_created")
    refreshPublicRangeCPowerUpBuff(keys,true)
end

function modifier_talent_range_b_on_destroy(keys)
    print("modifier_talent_range_b_on_destroy")
    refreshPublicRangeCPowerUpBuff(keys,false)

end

function refreshPublicRangeBPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_range_percent_final = ability:GetSpecialValueFor( "talent_range_percent_final")

    setPlayerPower(playerID, "talent_range_percent_final", flag, talent_range_percent_final)
end



function modifier_talent_damage_b_on_created(keys)
    print("modifier_talent_damage_b_on_created")
    refreshPublicDamageBPowerUpBuff(keys,true)
end

function modifier_talent_damage_b_on_destroy(keys)
    print("modifier_talent_damage_b_on_destroy")
    refreshPublicDamageBPowerUpBuff(keys,false)

end

function refreshPublicDamageBPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_percent_final = ability:GetSpecialValueFor( "talent_damage_percent_final")

    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, talent_damage_percent_final)
end



function modifier_talent_ability_speed_b_on_created(keys)
    print("modifier_talent_ability_speed_b_on_created")
    refreshPublicAbilitySpeedBPowerUpBuff(keys,true)
end

function modifier_talent_ability_speed_b_on_destroy(keys)
    print("modifier_talent_ability_speed_b_on_destroy")
    refreshPublicAbilitySpeedBPowerUpBuff(keys,false)

end

function refreshPublicAbilitySpeedBPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_ability_speed_percent_final = ability:GetSpecialValueFor( "talent_ability_speed_percent_final")

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, talent_ability_speed_percent_final)
end



function modifier_talent_control_b_on_created(keys)
    print("modifier_talent_control_b_on_created")
    refreshPublicControlBPowerUpBuff(keys,true)
end

function modifier_talent_control_b_on_destroy(keys)
    print("modifier_talent_control_b_on_destroy")
    refreshPublicControlBPowerUpBuff(keys,false)

end

function refreshPublicControlBPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_control_percent_final = ability:GetSpecialValueFor( "talent_control_percent_final")

    setPlayerPower(playerID, "talent_control_percent_final", flag, talent_control_percent_final)
end


function modifier_talent_damage_match_helper_b_on_created(keys)
    print("modifier_talent_damage_match_helper_b_on_created")
    refreshPublicDamageMatchHelperBPowerUpBuff(keys,true)
end

function modifier_talent_damage_match_helper_b_on_destroy(keys)
    print("modifier_talent_damage_match_helper_b_on_destroy")
    refreshPublicDamageMatchHelperBPowerUpBuff(keys,false)

end

function refreshPublicDamageMatchHelperBPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_match_helper_percent_final = ability:GetSpecialValueFor( "talent_damage_match_helper_percent_final")

    setPlayerPower(playerID, "talent_damage_match_helper_percent_final", flag, talent_damage_match_helper_percent_final)
end

--a级技能分界线

function modifier_talent_range_a_on_created(keys)
    print("modifier_talent_range_a_on_created")
    refreshPublicRangeAPowerUpBuff(keys,true)
end

function modifier_talent_range_a_on_destroy(keys)
    print("modifier_talent_range_a_on_destroy")
    refreshPublicRangeAPowerUpBuff(keys,false)

end

function refreshPublicRangeAPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_range_percent_final = ability:GetSpecialValueFor( "talent_range_percent_final")

    setPlayerPower(playerID, "talent_range_percent_final", flag, talent_range_percent_final)
end



function modifier_talent_damage_a_on_created(keys)
    print("modifier_talent_damage_a_on_created")
    refreshPublicDamageAPowerUpBuff(keys,true)
end

function modifier_talent_damage_a_on_destroy(keys)
    print("modifier_talent_damage_a_on_destroy")
    refreshPublicDamageAPowerUpBuff(keys,false)

end

function refreshPublicDamageAPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_percent_final = ability:GetSpecialValueFor( "talent_damage_percent_final")

    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, talent_damage_percent_final)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, talent_damage_percent_final)
end



function modifier_talent_ability_speed_a_on_created(keys)
    print("modifier_talent_ability_speed_a_on_created")
    refreshPublicAbilitySpeedAPowerUpBuff(keys,true)
end

function modifier_talent_ability_speed_a_on_destroy(keys)
    print("modifier_talent_ability_speed_a_on_destroy")
    refreshPublicAbilitySpeedAPowerUpBuff(keys,false)

end

function refreshPublicAbilitySpeedAPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_ability_speed_percent_final = ability:GetSpecialValueFor( "talent_ability_speed_percent_final")

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, talent_ability_speed_percent_final)
end



function modifier_talent_control_a_on_created(keys)
    print("modifier_talent_control_a_on_created")
    refreshPublicControlAPowerUpBuff(keys,true)
end

function modifier_talent_control_a_on_destroy(keys)
    print("modifier_talent_control_a_on_destroy")
    refreshPublicControlAPowerUpBuff(keys,false)

end

function refreshPublicControlAPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_control_a_percent_final = ability:GetSpecialValueFor( "talent_control_a_percent_final")

    setPlayerPower(playerID, "talent_control_a_percent_final", flag, talent_control_a_percent_final)
end


function modifier_talent_damage_match_helper_a_on_created(keys)
    print("modifier_talent_damage_match_helper_a_on_created")
    refreshPublicDamageMatchHelperAPowerUpBuff(keys,true)
end

function modifier_talent_damage_match_helper_a_on_destroy(keys)
    print("modifier_talent_damage_match_helper_a_on_destroy")
    refreshPublicDamageMatchHelperAPowerUpBuff(keys,false)

end

function refreshPublicDamageMatchHelperAPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local talent_damage_match_helper_a_percent_final = ability:GetSpecialValueFor( "talent_damage_match_helper_a_percent_final")

    setPlayerPower(playerID, "talent_damage_match_helper_a_percent_final", flag, talent_damage_match_helper_a_percent_final)
end