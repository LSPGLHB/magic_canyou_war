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


    setPlayerPower(playerID, "contract_damage_c_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "contract_damage_b_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "contract_damage_a_precent_final", flag, contract_damage_precent_final)

    setPlayerPowerFlag(playerID, "contract_control_flag", contract_control_flag)




end


