require('player_power')
function modifier_contract_battle_magician_on_created(keys)
    print("onCreated_battle_magician")
    refreshContractBuff(keys,true)
end

function modifier_contract_battle_magician_on_destroy(keys)
    print("onDestroy_battle_magician")
    refreshContractBuff(keys,false)
end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
 
    local contract_ability_speed_precent_final = ability:GetSpecialValueFor( "contract_ability_speed_precent_final")
    local contract_range_precent_final = ability:GetSpecialValueFor( "contract_range_precent_final")
    local contract_damage_precent_final = ability:GetSpecialValueFor( "contract_damage_precent_final")
    local contract_control_precent_final = ability:GetSpecialValueFor( "contract_control_precent_final")

    local contract_vision_flag = ability:GetSpecialValueFor( "contract_vision_flag")
    local contract_speed_flag = ability:GetSpecialValueFor( "contract_speed_flag")
    local contract_health_flag = ability:GetSpecialValueFor( "contract_health_flag")

    if (not flag) then
        contract_vision_flag = 1
        contract_speed_flag = 1
        contract_health_flag = 1
    end

    setPlayerPower(playerID, "contract_ability_speed_c_precent_final", flag, contract_ability_speed_precent_final)
    setPlayerPower(playerID, "contract_ability_speed_b_precent_final", flag, contract_ability_speed_precent_final)
    setPlayerPower(playerID, "contract_ability_speed_a_precent_final", flag, contract_ability_speed_precent_final)

    setPlayerPower(playerID, "contract_range_c_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "contract_range_b_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "contract_range_a_precent_final", flag, contract_range_precent_final)

    setPlayerPower(playerID, "contract_damage_c_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "contract_damage_b_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "contract_damage_a_precent_final", flag, contract_damage_precent_final)

    setPlayerPower(playerID, "contract_control_c_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "contract_control_b_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "contract_control_a_precent_final", flag, contract_control_precent_final)


    setPlayerPowerFlag(playerID, "contract_vision_flag", contract_vision_flag)
    setPlayerPowerFlag(playerID, "contract_speed_flag", contract_speed_flag)
    setPlayerPowerFlag(playerID, "contract_health_flag", contract_health_flag)


    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)

end


