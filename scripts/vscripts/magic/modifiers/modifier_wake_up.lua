modifier_wake_up_datadriven = class({})


function modifier_wake_up_datadriven:IsHidden()
    return ture
end

function modifier_wake_up_datadriven:GetEffectName()
	return "particles/hunshui_debuff_daxing.vpcf"
end

function modifier_wake_up_datadriven:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end