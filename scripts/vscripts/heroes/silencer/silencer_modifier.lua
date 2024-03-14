require('skill_operation')
require('player_power')

function buffOnCreated(keys)
    --print("buffOnCreated")
    refreshSilencerBuff(keys,true)
end

function buffOnDestroy(keys)
    --print("buffOnDestroy")
    refreshSilencerBuff(keys,false)
    local caster = keys.caster
    ParticleManager:DestroyParticle(caster.silencerPassiveParticlesID, true)
    caster.silencerPassiveParticlesID = nil
end


function refreshSilencerBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local range_up_bonus = ability:GetSpecialValueFor("range_up_bonus")
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent")

    setPlayerPower(playerID, "talent_range", flag, range_up_bonus)
    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, ability_speed_up_percent)  
                     
    setPlayerSimpleBuff(keys,"range")
end

function buffOnAbilityExecuted(keys)
    --print("buffOnAbilityExecuted")
    local caster = keys.caster
    local ability = keys.ability

    local powerUpModifier = "silencer_power_up_modifier"
    local currentStack = caster:GetModifierStackCount(powerUpModifier, ability)
    --print("currentStack:"..currentStack)
    caster.silencerPassiveStackCount = currentStack
    powerUpAbilityCount(caster, powerUpModifier, currentStack, shootOver, nil)

end

function shootOver(caster)
    local currentStack = caster.silencerPassiveStackCount
    local vx = 0
    local vy = 0
    local vz = 0
    if currentStack >= 1 then
        vx = 1
        if currentStack >= 2 then
            vy = 1
            if currentStack >= 3 then
                vz = 1
            end
        end
    end
    local particleID = caster.silencerPassiveParticlesID
    ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particleID, 1, Vector(vx,vy,vz))
end

--不知道干什么用的
function buffOnAbilityStart(keys)
    print("buffOnAbilityStart")
end

