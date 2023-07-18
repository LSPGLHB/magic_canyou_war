require('shoot_init')
require('skill_operation')
function createShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
        local playerID = caster:GetPlayerID()
		local speed = ability:GetSpecialValueFor("speed")
        local skillPoint = ability:GetCursorPosition()
	    local casterPoint = caster:GetAbsOrigin()
		local max_distance =  (skillPoint - casterPoint ):Length2D()--ability:GetSpecialValueFor("max_distance")
        local aoe_radius = ability:GetSpecialValueFor("aoe_radius")--半径
		local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
        local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,direction)
        initDurationBuff(keys)

        aoe_radius = getFinalValueOperation(playerID,aoe_radius,'control',shoot.abilityLevel,nil)--数值加强
		aoe_radius = getApplyControlValue(shoot, aoe_radius)--克制加强

        --过滤掉增加施法距离的操作
	    shoot.max_distance_operation = max_distance
        shoot.G_Speed = G_Speed
		shoot.aoe_duration = aoe_duration	
        shoot.aoe_radius = aoe_radius

		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.particleID = particleID
		EmitSoundOn(keys.soundCast, shoot)
		moveShoot(keys, shoot, spaceCollapseBoomCallBack, nil)
end

function spaceCollapseBoomCallBack(shoot)
    spaceCollapseRenderParticles(shoot)
    boomAOEOperation(shoot, spaceCollapseAOEOperationCallback)
end



--特效显示效果
function spaceCollapseRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local aoe_radius = shoot.aoe_radius

	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(aoe_radius, 0, 0))
end

function spaceCollapseAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local beatBackDistance = (shoot:GetAbsOrigin()-unit:GetAbsOrigin()):Length2D()
	local beatBackSpeed = ability:GetSpecialValueFor("G_speed") 
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,false,tfalseue)
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

