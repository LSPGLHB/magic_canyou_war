require('player_power')
function modifier_contract_damage_power_on_created(keys)
    print("onCreated_damage_power")
    refreshContractBuff(keys,true)
end

function modifier_contract_damage_power_on_destroy(keys)

    print("onDestroy_damage_power")

    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
 
    local contract_damage_precent_final = ability:GetSpecialValueFor( "contract_damage_precent_final")
    local contract_control_flag = ability:GetSpecialValueFor( "contract_control_flag")

    if (not flag) then
        contract_control_flag = 1
    end


    setPlayerPower(playerID, "player_damage_C_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_B_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_A_precent_final", flag, contract_damage_precent_final)

    setPlayerPowerFlag(playerID, "player_control_flag", contract_control_flag)




end


