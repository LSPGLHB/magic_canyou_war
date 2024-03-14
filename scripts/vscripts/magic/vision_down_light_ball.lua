require('shoot_init')
require('skill_operation')
require('player_power')
--禁视光球
vision_down_light_ball_datadriven = ({})
LinkLuaModifier("vision_down_light_ball_datadriven_modifier_debuff", "magic/modifiers/vision_down_light_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("vision_down_light_ball_datadriven_modifier_defense", "magic/modifiers/vision_down_light_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
function vision_down_light_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function vision_down_light_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function vision_down_light_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/16jinshiguangqiu_shengcheng.vpcf"
    keys.soundCast = "magic_vision_down_light_ball_cast" 
    keys.particles_power = "particles/16jinshiguangqiu_jiaqiang.vpcf"
    keys.soundPower = "magic_light_power_up"
    keys.particles_weak = "particles/16jinshiguangqiu_xueruo.vpcf"
    keys.soundWeak = "magic_light_power_down"
    keys.particles_duration = "particles/jinshiguangqiubaozha.vpcf"
    keys.soundBoom = "magic_light_aoe_boom"
    keys.soundDuration = "magic_light_aoe_duration"
    keys.soundDurationDelay = 0.5
    keys.soundWorking =	"magic_vision_down_light_ball_working"
    keys.soundDebuff =	"magic_vision_down_light_ball_debuff"
    keys.particles_defense = "particles/duobizhimangbuff_1.vpcf"
    keys.soundDefense = "magic_defence"
    keys.modifierDebuffName = "vision_down_light_ball_datadriven_modifier_debuff"
    keys.modifierDefenseName = "vision_down_light_ball_datadriven_modifier_defense"

    local playerID = caster:GetPlayerID()
    local skillPoint = ability:GetCursorPosition()
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
   
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    local AbilityLevel = shoot.abilityLevel

    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")    
    aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',AbilityLevel,nil)--数值加强
    aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
    shoot.aoe_duration = aoe_duration	


    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, visionDownLightBallDuration, nil)
    caster.shootOver = 1
end

function visionDownLightBallDuration(shoot)
    local keys = shoot.keysTable
    local interval = 0.5--伤害间隔
    visionDownLightBallRenderParticles(shoot)
    EmitSoundOn(keys.soundBoom, shoot)
    durationAOEDamage(shoot, interval, visionDownLightBallDamageCallback)
    local ability = keys.ability
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local judgeTime = ability:GetSpecialValueFor("vision_time")
    durationAOEJudgeByAngleAndTime(shoot, faceAngle, judgeTime,visionDebuffCallback)     

end

function visionDownLightBallDamageCallback(shoot, unit, interval)
	local keys = shoot.keysTable
	local caster = keys.caster
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)   
    local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
    --local modifierDefenseName = keys.modifierDefenseName
    if isface then   
        ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
        --[[
        if unit:HasModifier(modifierDefenseName) then
            unit:RemoveModifierByName(modifierDefenseName)
        end
    else]]
        --ability:ApplyDataDrivenModifier(caster, unit, modifierDefenseName, {Duration = -1})
        --unit:AddNewModifier(caster,ability,modifierDefenseName, {Duration = -1})
        --[[
        local defenceParticlesID =ParticleManager:CreateParticle(keys.particles_defense, PATTACH_OVERHEAD_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        --EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)]]
    end
    --[[
    if shoot.isKillAOE == 1 then
        if unit:HasModifier(modifierDefenseName) then
            unit:RemoveModifierByName(modifierDefenseName)
        end 
    end]]
end

function visionDownLightBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local groundPos = shoot:GetAbsOrigin()--GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
end

--视野debuff触发
function visionDebuffCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName

    if not unit:HasModifier(debuffName) then
        EmitSoundOn(keys.soundDebuff, shoot)
    end
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--数值加强
    debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(caster,ability,debuffName, {Duration = debuffDuration})

end

