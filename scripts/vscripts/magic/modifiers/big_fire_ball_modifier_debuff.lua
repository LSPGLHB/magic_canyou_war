big_fire_ball_pre_datadriven_modifier_debuff = class({})
function big_fire_ball_pre_datadriven_modifier_debuff:IsDebuff()
	return true
end

function big_fire_ball_pre_datadriven_modifier_debuff:GetEffectName()
	return "particles/zhimang_debuff.vpcf"
end

function big_fire_ball_pre_datadriven_modifier_debuff:GetEffectAttachType()
	return "follow_chest"
end

function big_fire_ball_pre_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end

function big_fire_ball_pre_datadriven_modifier_debuff:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end

function big_fire_ball_pre_datadriven_modifier_debuff:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end


big_fire_ball_datadriven_modifier_debuff = class({})
function big_fire_ball_datadriven_modifier_debuff:IsDebuff()
	return true
end

function big_fire_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/zhimang_debuff.vpcf"
end

function big_fire_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return "follow_chest"
end

function big_fire_ball_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end

function big_fire_ball_datadriven_modifier_debuff:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end

function big_fire_ball_datadriven_modifier_debuff:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end