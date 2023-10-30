require('player_power')
function modifier_contract_scout_on_created(keys)
    print("onCreated_battle_magician")
    refreshContractBuff(keys,true)
end

function modifier_contract_scout_on_destroy(keys)
    print("onDestroy_battle_magician")
    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
 
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_range_flag = ability:GetSpecialValueFor( "contract_range_flag")
    local contract_ability_speed_flag = ability:GetSpecialValueFor( "contract_ability_speed_flag")
    local contract_damage_flag = ability:GetSpecialValueFor( "contract_damage_flag")
    local contract_control_flag = ability:GetSpecialValueFor( "contract_control_flag")
    local contract_energy_flag = ability:GetSpecialValueFor( "contract_energy_flag")



    setPlayerPower(playerID, "contract_health_precent_final", flag, contract_health_precent_final)
    setPlayerPower(playerID, "contract_vision", flag, contract_vision)

    setPlayerPowerFlag(playerID, "contract_range_flag", contract_range_flag)
    setPlayerPowerFlag(playerID, "contract_ability_speed_flag", contract_ability_speed_flag)
    setPlayerPowerFlag(playerID, "contract_damage_flag", contract_damage_flag)
    setPlayerPowerFlag(playerID, "contract_control_flag", contract_control_flag)
    setPlayerPowerFlag(playerID, "contract_energy_flag", contract_energy_flag)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)


end


