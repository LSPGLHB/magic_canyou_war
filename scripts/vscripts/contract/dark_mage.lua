require('player_power')
function modifier_contract_dark_mage_on_created(keys)
    print("onCreated_dark_mage")
    refreshContractBuff(keys,true)
end

function modifier_contract_dark_mage_on_destroy(keys)
    print("onDestroy_dark_mage")
    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
 
    local contract_mana = ability:GetSpecialValueFor( "contract_mana")
    local contract_range_precent_final = ability:GetSpecialValueFor( "contract_range_precent_final")
    local contract_ability_speed_precent_final = ability:GetSpecialValueFor( "contract_ability_speed_precent_final")
    local contract_damage_precent_final = ability:GetSpecialValueFor( "contract_damage_precent_final")
    local contract_control_precent_final = ability:GetSpecialValueFor( "contract_control_precent_final")
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_speed = ability:GetSpecialValueFor( "contract_speed")
    local cooldown_precent_final = ability:GetSpecialValueFor( "cooldown_precent_final")





    setPlayerPower(playerID, "player_mana", flag, contract_mana)
    setPlayerPower(playerID, "player_vision", flag, contract_vision)
    setPlayerPower(playerID, "player_health_precent_final", flag, contract_health_precent_final)
    setPlayerPower(playerID, "player_speed", flag, contract_speed) 

    setPlayerPower(playerID, "player_range_c_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "player_range_b_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "player_range_a_precent_final", flag, contract_range_precent_final)

    setPlayerPower(playerID, "player_ability_speed_c_precent_final", flag, contract_ability_speed_precent_final)
    setPlayerPower(playerID, "player_ability_speed_b_precent_final", flag, contract_ability_speed_precent_final)
    setPlayerPower(playerID, "player_ability_speed_a_precent_final", flag, contract_ability_speed_precent_final)

    setPlayerPower(playerID, "player_damage_c_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_b_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_a_precent_final", flag, contract_damage_precent_final)

    setPlayerPower(playerID, "player_control_c_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_b_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_a_precent_final", flag, contract_control_precent_final)


    setPlayerPower(playerID, "player_cooldown_precent_final", flag, cooldown_precent_final * -1)


    setPlayerBuffByNameAndBValue(keys,"mana",GameRules.playerBaseMana)
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)

end


