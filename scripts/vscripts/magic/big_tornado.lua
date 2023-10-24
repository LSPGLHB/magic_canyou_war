require('shoot_init')
require('skill_operation')
function createShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
        local playerID = caster:GetPlayerID()
		--local speed = ability:GetSpecialValueFor("speed")
		local skillPoint = ability:GetCursorPosition()
	    local casterPoint = caster:GetAbsOrigin()
		local max_distance = (skillPoint - casterPoint ):Length2D()--ability:GetSpecialValueFor("max_distance")
        --local aoe_radius = ability:GetSpecialValueFor("aoe_radius")--半径
		
		local position = caster:GetAbsOrigin()
		local direction = (skillPoint - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,direction)
		initDurationBuff(keys)

		--效果可加强项目
		local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
        aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',shoot.abilityLevel,nil)--数值加强
		aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
		shoot.aoe_duration = aoe_duration
		local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
        G_Speed = getFinalValueOperation(playerID,G_Speed,'control',shoot.abilityLevel,nil)--数值计算
        G_Speed = getApplyControlValue(shoot, G_Speed)--克制加强
        shoot.G_Speed = G_Speed
		
        
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.particleID = particleID
		EmitSoundOn(keys.soundCast, shoot)
		moveShoot(keys, shoot, bigTornadoBoomCallBack, nil)
end

function bigTornadoBoomCallBack(shoot)
    bigTornadoDuration(shoot) --实现持续光环效果以及粒子效果
end

function bigTornadoDuration(shoot)
	local interval = 0.5
    bigTornadoRenderParticles(shoot)
    durationAOEDamage(shoot, interval, damageCallback)
	modifierHole(shoot)
	blackHole(shoot)
end

--特效显示效果
function bigTornadoRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	EmitSoundOn(keys.soundBoom, shoot)
	local aoe_radius = shoot.aoe_radius
    local aoe_duration = shoot.aoe_duration
	local shootPos = shoot:GetAbsOrigin()
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(aoe_radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 11, Vector(aoe_duration, 0, 0))
end



