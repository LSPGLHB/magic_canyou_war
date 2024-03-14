require('game_init')
require('shoot_init')
require('player_power')
item_damage_control_iceball = ({})
item_damage_control_iceball_2 = ({})
item_damage_control_iceball_3 = ({})
modifier_item_damage_control_iceball_datadriven = ({})
modifier_item_damage_control_iceball_2_datadriven = ({})
modifier_item_damage_control_iceball_3_datadriven = ({})
modifier_item_damage_control_iceball_debuff = ({})
LinkLuaModifier("modifier_item_damage_control_iceball_datadriven", "items/damage_control_iceball.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_iceball_2_datadriven", "items/damage_control_iceball.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_iceball_3_datadriven", "items/damage_control_iceball.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_iceball_debuff", "items/damage_control_iceball.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_damage_control_iceball:GetIntrinsicModifierName()
	return "modifier_item_damage_control_iceball_datadriven"
end

function item_damage_control_iceball_2:GetIntrinsicModifierName()
	return "modifier_item_damage_control_iceball_2_datadriven"
end

function item_damage_control_iceball_3:GetIntrinsicModifierName()
	return "modifier_item_damage_control_iceball_3_datadriven"
end

function modifier_item_damage_control_iceball_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_iceball_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_iceball_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_iceball_2_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_iceball_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_iceball_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_iceball_3_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_iceball_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_iceball_3_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end


function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base")
    local item_damage_percent_base = ability:GetSpecialValueFor("item_damage_percent_base")
    local item_health = ability:GetSpecialValueFor("item_health")   
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")

    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_damage_d_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_c_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_b_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_a_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)


    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)

end


function item_damage_control_iceball:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_damage_control_iceball:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'item')
	return aoe_radius
end

function item_damage_control_iceball:OnSpellStart()
    createShoot(self)
end

function item_damage_control_iceball_2:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_damage_control_iceball_2:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'item')
	return aoe_radius
end

function item_damage_control_iceball_2:OnSpellStart()
    createShoot(self)
end

function item_damage_control_iceball_3:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_damage_control_iceball_3:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'item')
	return aoe_radius
end

function item_damage_control_iceball_3:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local duration = ability:GetSpecialValueFor("duration")
    local casterPoint = caster:GetAbsOrigin()
    local targetPoint = ability:GetCursorPosition()
    local max_distance = (targetPoint - casterPoint):Length2D()
    local direction = (targetPoint - casterPoint):Normalized()

    local keys = getItemMagicKeys(ability)

    keys.particles_nm = "particles/zhuangbei_jiansudidai_faqiu.vpcf"
    keys.soundCast = "magic_ice_ball_cast"

    keys.particles_duration = "particles/zhuangbei_jiansudidai.vpcf"
    keys.soundBoom = "magic_small_hurricane_duration"

    keys.modifierDebuffName = "modifier_item_damage_control_iceball_debuff"

    keys.direction = direction
    keys.max_distance_operation = max_distance

    keys.speed = ability:GetSpecialValueFor("ability_speed") * GameRules.speedConstant * 0.02
    keys.damage = 0
    keys.hit_range = 10

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())

    creatTowerSkillInit(keys,shoot,caster)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.toPoint = targetPoint
    shoot.aoe_duration = duration
	shoot.aoeTargetDebuff = keys.modifierDebuffName
    shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    cannonMoveShoot(keys, shoot, itemIceBallCallback)

end

function itemIceBallCallback(shoot)
    --local interval = 0.5
    itemIceBallRenderParticles(shoot)
    --durationAOEDamage(shoot, interval, itemIceBallDamageCallback)目前不设伤害
   
    modifierHole(shoot)
    shootKill(shoot)
end

function itemIceBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    --ParticleManager:SetParticleControl(particleBoom, 5, Vector(shoot.aoe_radius, 0, 0))
    --ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
end

function modifier_item_damage_control_iceball_debuff:IsDebuff()
    return ture
end

function modifier_item_damage_control_iceball_debuff:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function modifier_item_damage_control_iceball_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_damage_control_iceball_debuff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_item_damage_control_iceball_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end
