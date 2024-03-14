require('shoot_init')
require('skill_operation')
require('player_power')
fire_arrow_bomb_datadriven = ({})
LinkLuaModifier( "fire_arrow_bomb_datadriven_modifier_debuff", "magic/modifiers/fire_arrow_bomb_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function fire_arrow_bomb_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function fire_arrow_bomb_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.cp = 				 9
    keys.particles_nm =      "particles/41huojianshu_shengcheng.vpcf"
    keys.soundCast = 		"magic_fire_arrow_bomb_cast"
    keys.particles_misfire = "particles/41huojianshu_jiluo.vpcf"
    keys.soundMisfire =		"magic_fire_mis_fire"
    keys.particles_miss =    "particles/41huojianshu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_fire_miss"
    
    keys.particles_power = 	"particles/41huojianshu_jiaqiang.vpcf"
    keys.soundPower =		"magic_fire_power_up"
    keys.particles_weak = 	"particles/41huojianshu_xueruo.vpcf"
    keys.soundWeak =			"magic_fire_power_down"	
    
    keys.particles_boom = 	"particles/41huojianshu_mingzhong.vpcf"
    keys.soundBoom =			"magic_fire_arrow_bomb_boom"

    keys.particles_timeover ="particles/41huojianshu_mingzhongbaozha.vpcf"
    keys.soundTimeover =		"magic_fire_arrow_bomb_timeover"

    keys.hitTargetDebuff =   "fire_arrow_bomb_datadriven_modifier_debuff"


    local skillPoint = ability:GetCursorPosition()
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
    moveShoot(keys, shoot, fireArrowBombBoomCallBack, nil)
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function fireArrowBombBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
	fireArrowBombBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, fireArrowBombAOEOperationCallback)
end
function fireArrowBombBoomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function fireArrowBombAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff   
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(unit,ability,hitTargetDebuff, {Duration = debuffDuration})

    Timers:CreateTimer(debuffDuration, function()
        local casterPoint = caster:GetAbsOrigin()
        local unitPoint = unit:GetAbsOrigin()
        local ucDistance = (unitPoint - casterPoint):Length2D()
        local max_distance = ability:GetSpecialValueFor("max_distance")
        --print("fireArrowBombAOEOperationCallback:",getApplyDamageValue(shoot))
        local damage = getApplyDamageValue(shoot) * (ucDistance / max_distance)
        ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		EmitSoundOn(keys.soundTimeover, shoot)
		local boomParticle = ParticleManager:CreateParticle(keys.particles_timeover, PATTACH_ABSORIGIN_FOLLOW , unit)
		ParticleManager:SetParticleControlEnt(boomParticle, 9 , unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
    end)

end 


