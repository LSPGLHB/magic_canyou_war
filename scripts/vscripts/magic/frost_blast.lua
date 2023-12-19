require('shoot_init')
require('skill_operation')
frost_blast_pre_datadriven = ({})
frost_blast_datadriven = ({})

LinkLuaModifier( "frost_blast_datadriven_modifier_debuff", "magic/modifiers/frost_blast_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
function frost_blast_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function frost_blast_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function frost_blast_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function frost_blast_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function frost_blast_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function frost_blast_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/44bingshuangchongji_shengcheng.vpcf"
    keys.soundCast =			"magic_frost_blast_cast"
    keys.particles_power = 	"particles/44bingshuangchongji_jiaqiang.vpcf"
    keys.soundPower =		"magic_water_power_up"
    keys.particles_weak = 	"particles/44bingshuangchongji_xueruo.vpcf"
    keys.soundWeak =			"magic_water_power_down"
    keys.particles_boom = 	"particles/44bingshuangchongji_baozha.vpcf"
    keys.soundBoom =			"magic_frost_blast_boom"
    keys.soundHit =			"magic_frost_blast_hit"
    keys.aoeTargetDebuff =   "frost_blast_datadriven_modifier_debuff"


    local skillPoint = ability:GetCursorPosition()
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
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, frostBlastBoomCallBack, nil)
    --[[
    local cooldown = ability:GetCooldownTimeRemaining() - 5
    ability:EndCooldown()
    ability:StartCooldown(cooldown)]]
end

--技能爆炸,单次伤害
function frostBlastBoomCallBack(shoot)
    ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    frostBlastRenderParticles(shoot) --爆炸粒子效果生成		  
	diffuseBoomAOEOperation(shoot, frostBlastAOECallback)
end
--调用特效
function frostBlastRenderParticles(shoot)
    local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local aoe_radius = shoot.aoe_radius
    local diffuseSpeed = ability:GetSpecialValueFor("diffuse_speed") * 1.66
    local cp1Y = aoe_radius / diffuseSpeed
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(diffuseSpeed, cp1Y, 0))--未实现传参
end
--伤害和buff运算
function frostBlastAOECallback(shoot,unit)
    local keys = shoot.keysTable
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local aoeTargetDebuff = keys.aoeTargetDebuff
    local isHitUnit = checkHitUnitToMark(shoot, unit, nil)
    if isHitUnit then
        local damage = getApplyDamageValue(shoot)
        EmitSoundOn(keys.soundHit, unit)
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
        debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--数值加强
        debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
        --ability:ApplyDataDrivenModifier(caster, unit, aoeTargetDebuff, {Duration = debuffDuration})
        unit:AddNewModifier(caster,ability,aoeTargetDebuff, {Duration = debuffDuration})
    end

end




