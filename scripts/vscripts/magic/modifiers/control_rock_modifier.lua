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
--[[
function control_rock_modifier_under_control:OnDestroy()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    --print("")
    initMagicStage(caster,ability:GetAbilityName())
end

function initMagicStage(caster,magicName)

	-- Swap main ability
	local ability_a_name = magicName --keys.ability_a_name
	local ability_b_name = magicName.."_stage_b" --keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
	--caster:InterruptMotionControllers( true )
end]]