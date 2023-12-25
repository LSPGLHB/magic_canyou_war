modifier_v_ice_ball_debuff_sp1_datadriven = ({})
function modifier_v_ice_ball_debuff_sp1_datadriven:IsDebuff()
	return true
end

function modifier_v_ice_ball_debuff_sp1_datadriven:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function modifier_v_ice_ball_debuff_sp1_datadriven:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_v_ice_ball_debuff_sp1_datadriven:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_v_ice_ball_debuff_sp1_datadriven:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function modifier_v_ice_ball_debuff_sp1_datadriven:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end


modifier_v_ice_ball_debuff_sp2_datadriven=({})
function modifier_v_ice_ball_debuff_sp2_datadriven:IsDebuff()
	return true
end

function modifier_v_ice_ball_debuff_sp2_datadriven:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function modifier_v_ice_ball_debuff_sp2_datadriven:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_v_ice_ball_debuff_sp2_datadriven:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_v_ice_ball_debuff_sp2_datadriven:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function modifier_v_ice_ball_debuff_sp2_datadriven:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end