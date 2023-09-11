require('player_power')
function modifier_contract_control_force_on_created(keys)
    print("onCreated_control_force")
    refreshContractBuff(keys,true)
end

function modifier_contract_control_force_on_destroy(keys)

    print("onDestroy_control_force")

    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local contract_control_precent_final = ability:GetSpecialValueFor( "contract_control_precent_final")
    local contract_damage_flag = ability:GetSpecialValueFor( "contract_damage_flag")

    --FLAG类，移除需要特别处理
    if (not flag) then
        contract_damage_flag = 1
    end

    setPlayerPower(playerID, "player_control_c_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_b_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_a_precent_final", flag, contract_control_precent_final)
    setPlayerPowerFlag(playerID, "player_damage_flag", contract_damage_flag)
end


