require('player_power')
function modifier_contract_tank_on_created(keys)
    print("onCreated_tank")
    refreshContractBuff(keys,true)
end

function modifier_contract_tank_on_destroy(keys)
    print("onDestroy_tank")
    refreshContractBuff(keys,false)
end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_speed_flag = ability:GetSpecialValueFor( "contract_speed_flag")
    if (not flag) then
        contract_speed_flag = 1
    end

    setPlayerPower(playerID, "contract_health_precent_final", flag, contract_health_precent_final)
    setPlayerPowerFlag(playerID, "contract_speed_flag", contract_speed_flag)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end
