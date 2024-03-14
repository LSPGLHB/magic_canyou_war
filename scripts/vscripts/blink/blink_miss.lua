require('game_init')
require('shoot_init')
require('player_power')
blink_miss = ({})
blink_miss_passive = ({})
LinkLuaModifier("blink_miss_passive", "blink/blink_miss.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_miss:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_miss:GetIntrinsicModifierName()
	return "blink_miss_passive"
end

function blink_miss:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    EmitSoundOn("scene_voice_blink_miss_cast", caster)
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local cooldown_reduce_percent = ability:GetSpecialValueFor("cooldown_reduce_percent")

    local particleName = "particles/shanxian_duobi.vpcf"
    local particleMissName = "particles/shanxian_duobi_fankui.vpcf"
    local direction = (skillPoint - casterPosition):Normalized()
    local distance = (skillPoint - casterPosition):Length2D()
    local newPosition = skillPoint
    if distance > max_distance then
        newPosition = casterPosition + direction * max_distance
    end


    local canWalk = GridNav:CanFindPath(casterPosition,newPosition)
      
    while not canWalk do
        newPosition = newPosition - direction * 10
        canWalk = GridNav:CanFindPath(casterPosition,newPosition)
    end
    caster:MoveToPosition(newPosition + direction * 1)
    caster:AddNoDraw()
    caster.isNoDraw = 1
    FindClearSpaceForUnit( caster, newPosition, false )

    local particleBlink = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleBlink, 0, casterPosition)
    ParticleManager:SetParticleControl(particleBlink, 1, newPosition)   
    local finishFlag = false
    local skillCount = 0
    Timers:CreateTimer(function()
        if finishFlag then 
            return nil
        end
        local lineUnits = FindUnitsInLine(caster:GetTeam(), 
                                        casterPosition,
                                        newPosition,
                                        nil,
										100,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0)
        for _, value in ipairs(lineUnits) do
            if (value:GetUnitLabel() == GameRules.skillLabel or value:GetUnitLabel() == GameRules.towerSkillLabel) and caster:GetTeam() ~= value:GetTeam() and value.blinkMissFlag == nil then
                value.blinkMissFlag = true
                skillCount = skillCount + 1
            end
        end

        return 0.02
    end)


    Timers:CreateTimer(0.25,function()
        finishFlag = true
        local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()
        local cooldownPercent = skillCount * (cooldown_reduce_percent / 100)
        if cooldownPercent > 1 then
            cooldownPercent = 1
        end
        cooldownTimeRemaining = cooldownTimeRemaining * (1 - cooldownPercent)
        ability:EndCooldown()
        ability:StartCooldown(cooldownTimeRemaining)
        caster:RemoveNoDraw()
        caster.isNoDraw = 0
        if skillCount > 0 then
            local particleMiss = ParticleManager:CreateParticle(particleMissName, PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:SetParticleControl(particleMiss, 0, caster:GetAbsOrigin())
        end
    end)

    caster.shootOver = -1
end

function blink_miss_passive:IsHidden()
    return true
end

function blink_miss_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkMissBuff(keys,true)
    end
end

function blink_miss_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkMissBuff(keys,false)
    end
end

function refreshBlinkMissBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local health_percent = ability:GetSpecialValueFor("health_percent") 
    local speed = ability:GetSpecialValueFor("speed")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_health_percent_final", flag, health_percent)
    setPlayerPower(playerID, "contract_speed", flag, speed)
    setPlayerPower(playerID, "contract_range", flag, range)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerSimpleBuff(keys,"range")

end