modifier_beat_back= class({})

function modifier_beat_back:IsDebuff()
	return true
end

function modifier_beat_back:GetEffectName()
	return "particles/jituiyangchenbuff.vpcf"
end

function modifier_beat_back:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_beat_back:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end


modifier_push_over= class({})

function modifier_push_over:IsDebuff()
	return true
end

function modifier_push_over:GetEffectName()
	return "particles/zhuangbei_tuituibang.vpcf"
end

function modifier_push_over:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_push_over:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_push_over:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_push_over:GetOverrideAnimation(keys)
    return ACT_DOTA_FLAIL
end