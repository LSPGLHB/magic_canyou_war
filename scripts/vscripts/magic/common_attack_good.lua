common_attack_good_datadriven = class({})

require('shoot_init')
require('skill_operation')
require('player_power')
require('scene/magic_stone')

function common_attack_good_datadriven:GetCastRange(t,v)
    --print("======GetCastRange========")
    local caster = self:GetCaster()
    --local ability = caster:GetAbilityByIndex(3)
    local range = self:GetSpecialValueFor("max_distance")
    --print("common_attack_good:"..range)
    --range = range + 500
	return range
end

function common_attack_good_datadriven:OnSpellStart()
    local caster = self:GetCaster()
    local skillPoint = self:GetCursorPosition()
    local speed = self:GetSpecialValueFor("speed")
    local max_distance = self:GetSpecialValueFor("max_distance")

    local keys = {}
    keys.caster = caster
	keys.ability = self
    keys.unitModel = "shootUnit-XS"--self:GetSpecialValueFor("unitModel")
    --print("keys.unitModel:"..self:GetSpecialValueFor("unitModel"))
    keys.AbilityLevel = "d"--self:GetSpecialValueFor("AbilityLevel")
    keys.unitType = "base"--self:GetSpecialValueFor("unitType")
    keys.hitType = 1--self:GetSpecialValueFor("hitType")
    keys.isMisfire = 1--self:GetSpecialValueFor("isMisfire")
    keys.particles_hit_dur = 0.7--self:GetSpecialValueFor("particles_hit_dur")
    keys.cp = 3--self:GetSpecialValueFor("cp")
    keys.particles_nm = "particles/yanggongji.vpcf"--self:GetSpecialValueFor("particles_nm")
    keys.soundCast = "magic_common_attack_good_cast"--self:GetSpecialValueFor("soundCast")
    keys.particles_misfire = "particles/yanggongji_jiluo.vpcf"--self:GetSpecialValueFor("particles_misfire")
    keys.soundMisfire = "magic_common_attack_good_mis_fire"--self:GetSpecialValueFor("soundMisfire")
    keys.particles_miss = "particles/yanggongji_xiaoshi.vpcf"--self:GetSpecialValueFor("particles_miss")
    keys.soundMiss = "magic_common_attack_good_miss"--self:GetSpecialValueFor("soundMiss")
    keys.particles_boom =  "particles/yanggongji_mingzhong.vpcf"--elf:GetSpecialValueFor("particles_boom")
    keys.soundBoom = "magic_common_attack_good_boom"--self:GetSpecialValueFor("soundBoom")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, commonAttackSp1BoomCallBack, nil)
end



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
    moveShoot(keys, shoot, commonAttackSp1BoomCallBack, nil)
end

--技能爆炸,单次伤害
function commonAttackSp1BoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    commonAttackSp1RenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, commonAttackSp1AOEOperationCallback)
end

function commonAttackSp1RenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function commonAttackSp1AOEOperationCallback(shoot,unit)
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
            magicStoneBroken(unit)
		end
	end
end