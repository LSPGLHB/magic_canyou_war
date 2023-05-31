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
    
 
    local contraccontract_health_precent_finalt_mana = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_range_flag = ability:GetSpecialValueFor( "contract_range_flag")
    local contract_ability_speed_flag = ability:GetSpecialValueFor( "contract_ability_speed_flag")
    local contract_damage_flag = ability:GetSpecialValueFor( "contract_damage_flag")
    local contract_control_flag = ability:GetSpecialValueFor( "contract_control_flag")
    local contract_energy_flag = ability:GetSpecialValueFor( "contract_energy_flag")



    setPlayerPower(playerID, "player_mana", flag, contract_health_precent_final)
    setPlayerPower(playerID, "player_vision", flag, contract_vision)

    setPlayerPowerFlag(playerID, "player_range_flag", contract_range_flag)
    setPlayerPowerFlag(playerID, "player_ability_speed_flag", contract_ability_speed_flag)
    setPlayerPowerFlag(playerID, "player_damage_flag", contract_damage_flag)
    setPlayerPowerFlag(playerID, "player_control_flag", contract_control_flag)
    setPlayerPowerFlag(playerID, "player_energy_flag", contract_energy_flag)

    setPlayerBuffByNameAndBValue(keys,"mana",GameRules.playerBaseMana)
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)


end


