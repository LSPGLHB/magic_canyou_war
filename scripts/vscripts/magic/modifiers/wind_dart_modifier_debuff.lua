modifier_wind_dart_lock = ({})
function modifier_wind_dart_lock:IsDebuff()
    return true
end

function modifier_wind_dart_lock:GetEffectName()
	return "particles/fengbiaosuoxing_debuff.vpcf"
end

function modifier_wind_dart_lock:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
