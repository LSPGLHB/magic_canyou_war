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