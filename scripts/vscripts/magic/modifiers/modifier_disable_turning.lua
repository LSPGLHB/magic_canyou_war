modifier_disable_turning = class({})

function modifier_disable_turning:IsDebuff()
	return true
end

function modifier_disable_turning:GetEffectName()
	return "particles/jiangzhi_debuff_bone.vpcf"
end

function modifier_disable_turning:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_disable_turning:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}
	return funcs
end

function modifier_disable_turning:GetModifierDisableTurning()
	return 1
end


