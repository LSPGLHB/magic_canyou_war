modifier_pingzhang_buff = ({})

function modifier_pingzhang_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_pingzhang_buff:GetOverrideAnimation(keys)
    return ACT_DOTA_CATS_ABILITY_4
end

function modifier_pingzhang_buff:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local unit = self:GetParent()
	
end

function modifier_pingzhang_buff:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local unit = self:GetParent()
	
end

--[[
function yinshen_modifier:CheckState()
	local state = {
        [MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end
]]
