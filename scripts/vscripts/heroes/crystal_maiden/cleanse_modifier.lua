require('player_power')
modifier_crystal_maiden_passive = ({})
--搜索自家碰撞减CD
function modifier_crystal_maiden_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.hitEnergySearchPassive = {}
        unit.hitEnergySearchPassive["abilityName"] = "npc_dota_hero_crystal_maiden_ability"
        unit.hitEnergySearchPassive["cooldownReduce"] = ability:GetSpecialValueFor("cooldown_reduce")
        unit.hitEnergySearchPassive["particlesName"] = "particles/jiekongge_beidong_cd.vpcf"
    end
end

function modifier_crystal_maiden_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.hitEnergySearchPassive = nil
    end
end

modifier_crystal_maiden_speed_up_passive = ({})
--加速
function modifier_crystal_maiden_speed_up_passive:IsBuff()
	return true
end

function modifier_crystal_maiden_speed_up_passive:GetEffectName()
	return "particles/jiekongge_buff.vpcf"
end
function modifier_crystal_maiden_speed_up_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_crystal_maiden_speed_up_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_crystal_maiden_speed_up_passive:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("speed_up")
end

modifier_crystal_maiden_control_up_passive = ({})
--5秒内下一次技能加控制效果
function modifier_crystal_maiden_control_up_passive:IsBuff()
	return true
end

function modifier_crystal_maiden_control_up_passive:GetEffectName()
	return "particles/jiekongge_beidong.vpcf"
end

function modifier_crystal_maiden_control_up_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_crystal_maiden_control_up_passive:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        --local playerID = unit:GetPlayerID()
        --local interval = 0.02
        local crystalMaidenControlCount = 2
        unit:SetModifierStackCount("modifier_crystal_maiden_control_up_passive",unit,crystalMaidenControlCount)

        local keys = {}
        keys.caster = unit
        keys.ability = self:GetAbility()
        refreshPowerUpBuff(keys,true)
        
    end
end

function modifier_crystal_maiden_control_up_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshPowerUpBuff(keys,false)
    end
end

function refreshPowerUpBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local control_up_percent = ability:GetSpecialValueFor("control_up_percent")

    setPlayerPower(playerID, "talent_control_percent_final", flag, control_up_percent)
end

function modifier_crystal_maiden_control_up_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

function modifier_crystal_maiden_control_up_passive:OnAbilityStart(keys)
    if IsServer() and keys.unit == self:GetParent() then
        local unit = self:GetParent()
        local modifierName = "modifier_crystal_maiden_control_up_passive"
        local crystalMaidenControlCount = unit:GetModifierStackCount(modifierName , unit )
        powerUpAbilityCount(unit, modifierName, crystalMaidenControlCount, nil, nil)
    end
end


