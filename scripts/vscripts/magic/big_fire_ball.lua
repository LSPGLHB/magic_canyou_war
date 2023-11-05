require('shoot_init')
require('skill_operation')
function createBigFireBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    --local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, bigFireBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function bigFireBallBoomCallBack(shoot)
    bigFireBallRenderParticles(shoot) --爆炸粒子效果生成		  
    --dealSkillbigFireBallBoom(keys,shoot) --实现aoe爆炸效果
	boomAOEOperation(shoot, AOEOperationCallback)
    --bigFireBallDuration(keys,shoot) --实现持续光环效果以及粒子效果
	--EndShootControl(keys)--遥控用
end

function bigFireBallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
	local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
	beatBackDistance = getFinalValueOperation(playerID,beatBackDistance,'control',AbilityLevel,nil)--装备数值加强
	beatBackDistance = getApplyControlValue(shoot, beatBackDistance)--相生加强

	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)
	local targetPos= unit:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,beatBackDirection,true)
	
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
	debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--装备数值加强
	debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
	local faceAngle = ability:GetSpecialValueFor("face_angle")
	local flag = isFaceByFaceAngle(shoot, unit, faceAngle)
	if flag then
		ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
	else
        local defenceParticlesID = ParticleManager:CreateParticle(keys.particles_defense, PATTACH_OVERHEAD_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)
	end
end




