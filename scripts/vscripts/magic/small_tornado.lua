require('shoot_init')
require('skill_operation')
function createShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
        local playerID = caster:GetPlayerID()

		local max_distance = ability:GetSpecialValueFor("max_distance")
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,direction)
		initDurationBuff(keys)

		local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
        aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',shoot.abilityLevel,nil)--数值加强
		aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
		shoot.aoe_duration = aoe_duration	
        local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
        G_Speed = getFinalValueOperation(playerID,G_Speed,'control',shoot.abilityLevel,nil)--数值计算
        G_Speed = getApplyControlValue(shoot, G_Speed)--克制计算
        shoot.G_Speed = G_Speed
		
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.particleID = particleID
		EmitSoundOn(keys.soundCast, shoot)
		moveShoot(keys, shoot, snallTornadoBoomCallBack, nil)
end

function snallTornadoBoomCallBack(shoot)
	
    snallTornadoRenderParticles(shoot)
    snallTornadoDuration(shoot) 
end

function snallTornadoDuration(shoot)
	local interval = 0.5
    shootSoundAndParticle(shoot, "boom")
    durationAOEDamage(shoot, interval, damageCallback)
	modifierHole(shoot)
	blackHole(shoot)
end

--特效显示效果
function snallTornadoRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	EmitSoundOn(keys.soundBoom, shoot)
	local aoe_radius = shoot.aoe_radius
    local aoe_duration = shoot.aoe_duration
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(aoe_radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 11, Vector(aoe_duration, 0, 0))
end



