clay_ball_datadriven_modifier_debuff= class({})

function clay_ball_datadriven_modifier_debuff:IsDebuff()
	return true
end

function clay_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/chanraoxiaoguo_debuff_1.vpcf"
end

function clay_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function clay_ball_datadriven_modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return state
end


