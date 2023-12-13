water_ball_datadriven_modifier_debuff = class({})

function water_ball_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function water_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function water_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function water_ball_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function water_ball_datadriven_modifier_debuff:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function water_ball_datadriven_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end


water_ball_pre_datadriven_modifier_debuff = class({})

function water_ball_pre_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function water_ball_pre_datadriven_modifier_debuff:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function water_ball_pre_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function water_ball_pre_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		--MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
	return funcs
end
--[[
function water_ball_pre_datadriven_modifier_debuff:GetModifierCastRangeBonus(keys)
    print("GetModifierCastRangeBonus")
    return  300
end
]]

function water_ball_pre_datadriven_modifier_debuff:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function water_ball_pre_datadriven_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end
