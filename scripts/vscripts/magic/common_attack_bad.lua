require('shoot_init')
require('skill_operation')
require('player_power')

function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, commonAttackSp2BoomCallBack, nil)

end

--技能爆炸,单次伤害
function commonAttackSp2BoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    commonAttackSp2RenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, commonAttackSp2AOEOperationCallback)
end

function commonAttackSp2RenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function commonAttackSp2AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local damage = getApplyDamageValue(shoot)
	local unitLabel = unit:GetUnitLabel()
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	if unitLabel == GameRules.magicStoneLabel then
		ApplyDamage({victim = unit, attacker = caster, damage = 1, damage_type = DAMAGE_TYPE_PURE})
		if not unit:IsAlive() then
			unit.alive = 0
		end
	end
end	