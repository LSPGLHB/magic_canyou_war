require('player_power')
function modifier_contract_guerrilla_force_on_created(keys)
    print("onCreated_guerrilla_force")
    refreshContractBuff(keys,true)
end

function modifier_contract_guerrilla_force_on_destroy(keys)
    print("onDestroy_guerrilla_force")
    refreshContractBuff(keys,false)
end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local contract_speed = ability:GetSpecialValueFor( "contract_speed")
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")

    local contract_vision_flag = ability:GetSpecialValueFor( "contract_vision_flag")


    if (not flag) then
        contract_vision_flag = 1
    end
    setPlayerPowerFlag(playerID, "contract_vision_flag", contract_vision_flag)

    setPlayerPower(playerID, "contract_speed", flag, contract_speed)
    setPlayerPower(playerID, "contract_vision", flag, contract_vision)

    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)


end
