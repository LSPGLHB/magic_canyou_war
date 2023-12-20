require('shoot_init')
require('skill_operation')
require('player_power')
light_ball_datadriven =({})
LinkLuaModifier("light_ball_datadriven_modifier_debuff", "magic/modifiers/light_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function light_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function light_ball_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/01yaoyanguangqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_light_ball_cast"
    keys.particles_power = 	"particles/01yaoyanguangqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_light_power_up"
    keys.particles_weak = 	"particles/01yaoyanguangqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_light_power_down"
    keys.particles_boom = 	"particles/yaoyanguangqiubaozha.vpcf"
    keys.soundBoom =			"magic_light_ball_boom"
    keys.modifierDebuffName =  "light_ball_datadriven_modifier_debuff"
    keys.particles_defense = "particles/duobizhimangbuff_1.vpcf"
    keys.soundDefense =      "magic_defence"

    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local directionTable ={}
    local angle23 = angleRate * math.pi
    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, direction.z)
    table.insert(directionTable,direction3)
    initDurationBuff(keys)
    for i = 1, 2, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])

        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        moveShoot(keys, shoot, lightBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function lightBallBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    lightBallRenderParticles(shoot) --爆炸粒子效果生成		  
    --dealSkilllightBallBoom(keys,shoot) --实现aoe爆炸效果
    boomAOEOperation(shoot, lightBallAOEOperationCallback)
end

function lightBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 1))
end

function lightBallAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
    local damage = getApplyDamageValue(shoot) / 2
    
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local flag = isFaceByFaceAngle(shoot, unit, faceAngle)
    if flag then
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
        debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
        debuffDuration = getApplyControlValue(shoot, debuffDuration)
        --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
        unit:AddNewModifier(caster,ability,debuffName, {Duration = debuffDuration})
    else
        local defenceParticlesID =ParticleManager:CreateParticle(keys.particles_defense, PATTACH_OVERHEAD_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)
    end

end


