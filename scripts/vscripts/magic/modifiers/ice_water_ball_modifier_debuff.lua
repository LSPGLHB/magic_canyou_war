ice_water_ball_datadriven_modifier_debuff_sp1=({})

function ice_water_ball_datadriven_modifier_debuff_sp1:IsDebuff()
    return ture
end

function ice_water_ball_datadriven_modifier_debuff_sp1:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function ice_water_ball_datadriven_modifier_debuff_sp1:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ice_water_ball_datadriven_modifier_debuff_sp1:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function ice_water_ball_datadriven_modifier_debuff_sp1:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end


ice_water_ball_datadriven_modifier_debuff_sp2=({})

function ice_water_ball_datadriven_modifier_debuff_sp2:IsDebuff()
    return ture
end

function ice_water_ball_datadriven_modifier_debuff_sp2:GetEffectName()
	return "particles/zhuanshen_debuff.vpcf"
end

function ice_water_ball_datadriven_modifier_debuff_sp2:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ice_water_ball_datadriven_modifier_debuff_sp2:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
	return funcs
end

function ice_water_ball_datadriven_modifier_debuff_sp2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end




