twine_soil_ball_datadriven_modifier_debuff = class({})

function twine_soil_ball_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function twine_soil_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/chanraoxiaoguo_debuff_1.vpcf"
end

function twine_soil_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function twine_soil_ball_datadriven_modifier_debuff:CheckState()
	local state = {
        --[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end


twine_soil_ball_pre_datadriven_modifier_debuff = class({})

function twine_soil_ball_pre_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function twine_soil_ball_pre_datadriven_modifier_debuff:GetEffectName()
	return "particles/chanraoxiaoguo_debuff_1.vpcf"
end

function twine_soil_ball_pre_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function twine_soil_ball_pre_datadriven_modifier_debuff:CheckState()
	local state = {
        --[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end