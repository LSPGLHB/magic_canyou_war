modifier_rubick_passive = ({})
function modifier_rubick_passive:OnCreated()
	if IsServer() and self:GetParent():IsAlive() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
        local unit = self:GetParent()
		local casterTeam = caster:GetTeam()
		local radius = ability:GetSpecialValueFor("aoe_radius")
		unit.rubickPassiveInterval = 0.02
		unit.rubickPassive = {}
		unit.rubickPassive["abilityName"] = "npc_dota_hero_rubick_ability"
		unit.rubickPassive["cooldownReduce"] = ability:GetSpecialValueFor("cooldown_reduce")
		unit.rubickPassive["particlesName"] = "particles/qianyinge_beidong.vpcf"
		unit.rubickPassive["aoe_radius"] = radius
		unit.rubickPassive["faceAngle"] = ability:GetSpecialValueFor("face_angle")
		
		Timers:CreateTimer(function()
			local tempSkillUnits = {}
			local workFlag = false
			local position = caster:GetAbsOrigin()
			local aroundUnits = FindUnitsInRadius(casterTeam, 
											position,
											nil,
											radius,
											DOTA_UNIT_TARGET_TEAM_BOTH,
											DOTA_UNIT_TARGET_ALL,
											0,
											0,
											false)


			for _, unit in ipairs(aroundUnits) do
				local targetLabel = unit:GetUnitLabel()
				local unitEnergy = unit.energy_point
				if(GameRules.skillLabel == targetLabel and unit.hitEnergyRubickSearch == nil and unitEnergy ~= 0 ) then
					unit.hitEnergyRubickSearch = radius
				end
			end

			return unit.rubickPassiveInterval
		end)
	end
end
function modifier_rubick_passive:OnDestroy()
    if IsServer() then
		local unit = self:GetParent()
        unit.rubickPassiveInterval = nil
    end
end

modifier_rubick_pull_caster_buff=({})
function modifier_rubick_pull_caster_buff:IsBuff()
	return true
end

function modifier_rubick_pull_caster_buff:GetEffectName()
	return "particles/wanxiangtianyin_fashe.vpcf"
end

function modifier_rubick_pull_caster_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_rubick_pull_caster_buff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

modifier_rubick_pull_target_buff = ({})

function modifier_rubick_pull_target_buff:IsBuff()
    return true
end

function modifier_rubick_pull_target_buff:GetEffectName()
	return "particles/jituiyangchenbuff.vpcf"
end

function modifier_rubick_pull_target_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rubick_pull_target_buff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_rubick_pull_target_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_rubick_pull_target_buff:GetOverrideAnimation(keys)
    return ACT_DOTA_FLAIL
end

