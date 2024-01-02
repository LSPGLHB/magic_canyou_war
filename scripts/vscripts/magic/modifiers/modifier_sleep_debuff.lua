
LinkLuaModifier( "modifier_wake_up_datadriven", "magic/modifiers/modifier_wake_up.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

modifier_sleep_debuff_datadriven = class({})

function modifier_sleep_debuff_datadriven:IsDebuff()
    return true
end

function modifier_sleep_debuff_datadriven:GetEffectName()
	return "particles/hunshui_debuff.vpcf"
end

function modifier_sleep_debuff_datadriven:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sleep_debuff_datadriven:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_sleep_debuff_datadriven:GetOverrideAnimation(keys)
    return ACT_DOTA_DISABLED
end

function modifier_sleep_debuff_datadriven:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        --[MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end


function modifier_sleep_debuff_datadriven:OnCreated()
    if IsServer() then
        if not self:GetAbility() then 
            self:Destroy() 
        end
    end
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
end

function modifier_sleep_debuff_datadriven:OnDestroy()
    local caster = self.caster
    local ability = self.ability
    if self.ability then
        if IsServer() then
            EmitSoundOn("magic_wake_up",caster)
            caster:AddNewModifier(caster,ability,"modifier_wake_up_datadriven", {Duration = 1} )
        end
    end
end

if IsServer() then
    function modifier_sleep_debuff_datadriven:OnTakeDamage(keys)
        --print("OnTakeDamage")
        local caster = self.caster
        caster:RemoveModifierByName('modifier_sleep_debuff_datadriven')
    end
end


