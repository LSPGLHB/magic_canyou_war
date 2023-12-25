control_rock_modifier_under_control= class({})

function control_rock_modifier_under_control:IsBuff()
	return true
end

function control_rock_modifier_under_control:GetEffectName()
	return "particles/37yinianyanji_buff.vpcf"
end

function control_rock_modifier_under_control:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function control_rock_modifier_under_control:GetOverrideAnimation(keys)
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function control_rock_modifier_under_control:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return state
end


function control_rock_modifier_under_control:OnDestroy()
	if IsServer() then
        local ability = self:GetAbility()
        local magicName = ability:GetAbilityName()
        local unit = self:GetParent()
        local ability_a_name = magicName
        local ability_b_name = magicName.."_stage_b"
        --print("OnDestroy:"..magicName)
        if not unit:IsNull() then
            unit:SwapAbilities( ability_a_name, ability_b_name, true, false )
        end
    end
end