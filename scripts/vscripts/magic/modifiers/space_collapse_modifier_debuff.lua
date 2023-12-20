modifier_space_collapse_aoe_debuff=({})

function modifier_space_collapse_aoe_debuff:IsDebuff()
    return true
end

function modifier_space_collapse_aoe_debuff:GetEffectName()
	return "particles/jituiyangchenbuff.vpcf"
end

function modifier_space_collapse_aoe_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
