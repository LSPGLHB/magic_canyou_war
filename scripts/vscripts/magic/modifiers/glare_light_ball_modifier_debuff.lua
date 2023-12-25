glare_light_ball_datadriven_modifier_debuff = class({})
function glare_light_ball_datadriven_modifier_debuff:IsDebuff()
	return true
end

function glare_light_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/zhimang_debuff.vpcf"
end

function glare_light_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function glare_light_ball_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end

function glare_light_ball_datadriven_modifier_debuff:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end

function glare_light_ball_datadriven_modifier_debuff:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_radius")
end