-- Generated from template

require('game_init')
require('player_power')
require('game_progress')
require('get_magic')
require('get_contract')
require('get_talent')
require('shop')
require('button')
require('player_status')
require('util')
require('timers')
require('physics')
require('barebones')

if magicCanyouWar == nil then
	magicCanyouWar = class({})
end

function PrecacheEveryThingFromKV( context )
	local kv_files = {
		"scripts/npc/npc_units_custom.txt",
		"scripts/npc/npc_abilities_custom.txt",
		"scripts/npc/npc_abilities_override.txt",
		"scripts/npc/npc_heroes_custom.txt",
		"scripts/npc/npc_items_custom.txt",
		"scripts/npc/scene/gold_coin.kv"
	}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
end

function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then 	
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end

   
end

function Precache( context )

	print("BEGIN TO PRECACHE RESOURCE")
--[[
	local time = GameRules:GetGameTime()
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")
]]
	PrecacheEveryThingFromKV( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	PrecacheResource("particle_folder", "particles/test_particle", context)
	-- Models can also be precached by folder or individually
	-- PrecacheModel should generally used over PrecacheResource for individual models
	PrecacheResource("model_folder", "particles/heroes/antimage", context)
	--PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
	--PrecacheModel("models/heroes/viper/viper.vmdl", context)
	-- Sounds can precached here like anything else
	--PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
	-- Entire items can be precached by name
	-- Abilities can also be precached in this way despite the name
	PrecacheItemByNameSync("example_ability", context)
	PrecacheItemByNameSync("item_example_item", context)
	-- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
	-- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
	PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
	PrecacheUnitByNameSync("npc_dota_hero_enigma", context)

--[[
	print("Precache...")
    local precache_list = require("precache")
	for _, precache_item in pairs(precache_list) do
		--预载precache.lua里的资源
		if string.find(precache_item, ".vpcf") then
			-- print('[precache]'..precache_item)
			PrecacheResource( "particle",  precache_item, context)
		end
		if string.find(precache_item, ".vmdl") then 	
			-- print('[precache]'..precache_item)
			PrecacheResource( "model",  precache_item, context)
		end
		if string.find(precache_item, ".vsndevts") then
			-- print('[precache]'..precache_item)
			PrecacheResource( "soundfile",  precache_item, context)
		end
		if string.find(precache_item, ".v") == false then
			-- print('[precache]'..precache_item)
			PrecacheResource( "particle_folder",  precache_item, context)
		end
    end
]]
	--此处开始比较有用
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_magic.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_scene.vsndevts", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = magicCanyouWar()
	GameRules.AddonTemplate:InitGameMode()
end

function magicCanyouWar:InitGameMode()
	print( "============Init Game Mode============" )
	--GameRules:AddBotPlayerWithEntityScript("npc_dota_hero_lina","bot",DOTA_TEAM_GOODGUYS,nil,false) --开启机器人电脑
	--GameRules:SetHeroSelectionTime(20)--选英雄时间(可用)
	GameRules:SetStrategyTime(0) --选英雄了后选装备时间（可用）
	--GameRules:SetShowcaseTime(20)
	--GameRules:SetTreeRegrowTime(60) -- 设置树木重生时间
	--GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0) --物品交换冷却
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(16) --英雄最高等级
	GameRules:SetCustomGameEndDelay(1)--设置游戏结束等待时间
	--GameRules:SetCustomGameSetupTimeout(1) --0后无法选英雄？？？设置设置(赛前)阶段的超时。 0 = 立即开始, -1 = 永远 (直到FinishCustomGameSetup 被调用) 
	--GameRules:SetCustomGameSetupAutoLaunchDelay(0)--设置自动开始前的等待时间。 

	GameRules.PreTime = 2  --开局延迟吹号角
	GameRules.refreshCost = 10    --刷新需要金币
	GameRules.refreshCostAdd = 10 --刷新叠加金币
	GameRules.studyTime = 21   --学习阶段时间
	GameRules.prepareTime = 21 --策略阶段时间
	GameRules.battleTime = 300 --战斗阶段时间
	GameRules.centerTreasureBoxTime = GameRules.battleTime - 45 --中央宝箱出现时间
	GameRules.decisiveBattleTime = 150 --剩余时间决战阶段
	GameRules.battlefieldTimer = 30 --法阵激活间隔
	GameRules.freeTime = 5 --战后自由活动时间
	GameRules.remainsBoxAliveTime = 15 --遗物箱消失时间
	GameRules.roundEndLoadingTime = 3.5 --轮回石运转时间
	

	GameRules.winBaseReward = 7 --基础胜方奖励
	GameRules.loseBaseReward = 21 --基础败方奖励
	GameRules.seriesWinReward = {7,21} -- 2,3+连胜额外奖励
	GameRules.endSeriesWinReward = {14,28} --终结2,3+连胜奖励

	GameRules.magicStoneLabel = "magicStoneLabel"
	GameRules.skillLabel = "skillLabel"
	GameRules.summonLabel = "summonLabel"  --可被攻击的召唤

	
	GameRules.nothingLabel ="nothingLabel" --抛物线用或其他不可被攻击的
	GameRules.stoneLabel = "stoneLabel"
	GameRules.shopLabel ="shopLabel"
	GameRules.boxLabel = "boxLabel"
	GameRules.battlefieldLabel = "battlefieldLabel"
	GameRules.samsaraStoneLabel = "samsaraStoneLabel"
	GameRules.remainsLabel ="remainsLabel" --遗物

	GameRules.checkWinTeam = nil
	GameRules.testMode = false

	--场景标签，一般不与子弹互动
	GameRules.SceneLabel = {}
	GameRules.SceneLabel[1] = GameRules.nothingLabel
	GameRules.SceneLabel[2] = GameRules.stoneLabel
	GameRules.SceneLabel[3] = GameRules.shopLabel
	GameRules.SceneLabel[4] = GameRules.boxLabel
	GameRules.SceneLabel[5] = GameRules.battlefieldLabel
	GameRules.SceneLabel[6] = GameRules.samsaraStoneLabel
	GameRules.SceneLabel[7] = GameRules.remainsLabel


	GameRules.playerBaseHealth = 50 --基础血量
	GameRules.playerBaseMana = 100  --基础蓝量
	GameRules.playerBaseSpeed = 250 --基础移速
	GameRules.playerBaseVision = 1100 --基础视野
	GameRules.playerBaseManaRegen = 5 --基础回蓝
	GameRules.playerBaseDefense = 0   -- 基础防御


	GameRules.speedConstant  = 1.66  --弹道速度换算常数

	GameRules:SetPreGameTime(GameRules.PreTime) --选择英雄与开始时间，吹号角时间
	GameRules:SetStartingGold(0)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetUseBaseGoldBountyOnHeroes(true)
	--GameRules:SetHideKillMessageHeaders(true)--隐藏击杀提示
	GameRules:SetHeroRespawnEnabled(false)  --复活规则

	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetDaynightCycleDisabled(true)
	GameMode:SetCameraDistanceOverride(1134) -- 默认1134
	--GameRules:SetHeroSelectPenaltyTime( 0.0 )
--[[用了启动会跳出
	GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0)
	GameRules:GetGameModeEntity():SetPauseEnabled(false)
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(false)
    GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():DisableHudFlip(true)
	GameRules:GetGameModeEntity():SetSendToStashEnabled(false)
]]

	self._GameMode = GameRules:GetGameModeEntity()
	self.CurrentScenario = nil
	self.flNextTimerConsoleNotify = -1

	GameRules.DropTable = LoadKeyValues("scripts/kv/drops.kv") -- 导入掉落率的列表
	GameRules.customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")--导入技能表

	GameRules.itemList = LoadKeyValues("scripts/npc/npc_items_custom.txt")--导入装备表
	GameRules.contractList = LoadKeyValues("scripts/npc/contract/contract_all.kv")--导入契约表

	GameRules.talentCList = LoadKeyValues("scripts/npc/talent/talent_c.kv")--导入提升天赋
	GameRules.talentBList = LoadKeyValues("scripts/npc/talent/talent_b.kv")
	GameRules.talentAList = LoadKeyValues("scripts/npc/talent/talent_a.kv")

	GameRules.goldCoin = LoadKeyValues("scripts/npc/scene/gold_coin.kv")--导入金币

	

	--设置队伍组合

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	--GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 5 )
	--GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 5 )


	--GameRules:SetPostGameTime( 0.0 )
	--GameRules:SetGoldPerTick( 0 )
	--GameRules:SetCustomGameAccountRecordSaveFunction( Dynamic_Wrap( magicCanyouWar, "OnSaveAccountRecord" ), self )

	--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	--监听单位被击杀
	ListenToGameEvent("entity_killed", Dynamic_Wrap(magicCanyouWar, "OnEntityKilled"), self)

	--ListenToGameEvent("dota_player_kill", Dynamic_Wrap(magicCanyouWar, "OnPlayerKill"), self)


	--监听单位重生
	--ListenToGameEvent("npc_spawned", Dynamic_Wrap(magicCanyouWar, "OnNPCSpawned"), self)

	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(magicCanyouWar,"OnGameRulesStateChange"), self)
	

	--监听物品被捡起 --捡起无法确定物品所有者，弃用自己重做一套
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(magicCanyouWar, "OnItemPickup"), self)



	--监听UI事件,这是按钮事件管理器 --(监听名，回调函数)
	CustomGameEventManager:RegisterListener( "js_to_lua", OnJsToLua )

	--商店按钮监听
	CustomGameEventManager:RegisterListener( "openShopJSTOLUA", openShopJSTOLUA )  
	CustomGameEventManager:RegisterListener( "closeShopJSTOLUA", closeShopJSTOLUA )  
	CustomGameEventManager:RegisterListener( "refreshShopJSTOLUA", refreshShopJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "buyShopJSTOLUA", buyShopJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "lockShopJSTOLUA", lockShopJSTOLUA )

	--信息板按钮
	CustomGameEventManager:RegisterListener( "openPlayerStatusJSTOLUA", openPlayerStatusJSTOLUA )
	CustomGameEventManager:RegisterListener( "closePlayerStatusJSTOLUA", closePlayerStatusJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshPlayerStatusJSTOLUA", refreshPlayerStatusJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "getContractDetailByNumJSTOLUA", getContractDetailByNumJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "getMagicDetailByNumJSTOLUA", getMagicDetailByNumJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "getItemDetailByNumJSTOLUA", getItemDetailByNumJSTOLUA ) 
	
	--契约列表
	--CustomGameEventManager:RegisterListener( "openContractListJSTOLUA", openContractListJSTOLUA ) --打开启用KVTPLUA通道
	CustomGameEventManager:RegisterListener( "closeContractListJSTOLUA", closeContractListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshContractListJSTOLUA", refreshContractListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "learnContractByNameJSTOLUA", learnContractByNameJSTOLUA ) 

	--天赋列表
	CustomGameEventManager:RegisterListener( "closeTalentListJSTOLUA", closeTalentListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshTalentListJSTOLUA", refreshTalentListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "learnTalentByNameJSTOLUA", learnTalentByNameJSTOLUA ) 

	--学习技能
	CustomGameEventManager:RegisterListener( "closeMagicListJSTOLUA", closeMagicListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshMagicListJSTOLUA", refreshMagicListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "learnMagicByNameJSTOLUA", learnMagicByNameJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "rebuildMagicByNameJSTOLUA", rebuildMagicByNameJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "getRebuildMagicListByNameJSTOLUA", getRebuildMagicListByNameJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "getRandomGoldJSTOLUA", getRandomGoldJSTOLUA ) 
	
	--测试的家伙
	CustomGameEventManager:RegisterListener( "OnTestUIOpen", OnTestUIOpen )
	CustomGameEventManager:RegisterListener( "buttonaJSTOLUA", buttonaJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonbJSTOLUA", buttonbJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttoncJSTOLUA", buttoncJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttondJSTOLUA", buttondJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttoneJSTOLUA", buttoneJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonfJSTOLUA", buttonfJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttongJSTOLUA", buttongJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonhJSTOLUA", buttonhJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttoniJSTOLUA", buttoniJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonjJSTOLUA", buttonjJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonkJSTOLUA", buttonkJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonlJSTOLUA", buttonlJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonmJSTOLUA", buttonmJSTOLUA )
	CustomGameEventManager:RegisterListener( "buttonnJSTOLUA", buttonnJSTOLUA )

	--测试快捷键
	CustomGameEventManager:RegisterListener("ed_open_my_shop", function(_, keys)
		self:On_ed_open_my_shop(keys)
	end)



	--金币过滤器(清理所有dota金币逻辑)
	local gameSelf = GameRules:GetGameModeEntity()
	gameSelf:SetModifyGoldFilter(function(keys)
		return false
   end,gameSelf)

   GameRules:GetGameModeEntity():SetModifyExperienceFilter(function(keys)
	return false
   end,self)

   
end


function magicCanyouWar:On_ed_open_my_shop(keys)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	--print("On_ed_open_my_shop"..keys.PlayerID)
end

function magicCanyouWar:OnEntityKilled (keys)
	local unit = EntIndexToHScript(keys.entindex_killed) --受害者
	local killer = EntIndexToHScript(keys.entindex_attacker) --凶手
    local name = unit:GetContext("name")
	local label = unit:GetUnitLabel()
	local position = unit:GetAbsOrigin()
	local killerTeam = killer:GetTeam()
	local killerID = killer:GetPlayerID()

	if name == "testdog" then
		--测试流程面板
		CustomUI:DynamicHud_Create(killerID,"UITestPanelBG","file://{resources}/layout/custom_game/UI_test.xml",nil)
		GameRules.testMode = true
	end
	
	--物品掉落测试(金币箱子打开)
	if label == GameRules.boxLabel then
		RollDrops(unit)
	end

	if unit:IsHero() then
		local remainsBoxAliveTime = GameRules.remainsBoxAliveTime
		local timeCount = 5--remainsBoxAliveTime
		local dorpUnit = CreateUnitByName("heroDropUnit", position, true, nil, nil, killerTeam)
		dorpUnit:GetAbilityByIndex(0):SetLevel(1)
		if killerTeam == DOTA_TEAM_GOODGUYS then
			dorpUnit:SetSkin(0)
		end
		if killerTeam == DOTA_TEAM_BADGUYS then
			dorpUnit:SetSkin(1)
		end

		dorpUnit.alive = 1
		table.insert(remainsBox,dorpUnit)

		--遗物如果未捡自动消失
		Timers:CreateTimer(1,function()
			timeCount = timeCount - 1
			if timeCount <= 0 and dorpUnit.alive == 1 then
				dorpUnit:ForceKill(true)
				dorpUnit.alive = 0
				dorpUnit:SetModelScale(0.01)
				return nil
			end
			return 1
		end)

		local killerBonus = 8  --击杀者获得金币数
		local teamBonus = 4 --击杀者队友获得金币数
		local unitID = unit:GetPlayerID()
		local endPlayerSeriesKill = playerSeriesKill[unitID]
		--print('playerDie--alreadyKill:'..endPlayerSeriesKill)
		if endPlayerSeriesKill >= 3 then
			killerBonus = killerBonus + 4 * 3
		end
		--被击杀玩家连续击杀数清0
		playerSeriesKill[unitID] = 0
		--击杀者连续击杀数+1
		playerSeriesKill[killerID] = playerSeriesKill[killerID] + 1
		--击杀者金币增加
		PlayerResource:SetGold(killerID, killer:GetGold()+killerBonus, true)
		showGoldWorthParticle(killerID,killerBonus,"team")
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
				local hHero = PlayerResource:GetSelectedHeroEntity(playerID) 
				local hHeroTeam = hHero:GetTeam()
				if hHeroTeam == killerTeam and killerID ~= playerID then
					PlayerResource:SetGold(playerID, hHero:GetGold()+teamBonus, true)
					showGoldWorthParticle(playerID,teamBonus,"team")
				end
			end
		end
	end

	--判断小怪被消灭，并刷新小怪
	if name then
		if name == "yang" then
			createUnit("yang",DOTA_TEAM_BADGUYS)
		end
		if name == "niu" then
			createUnit("niu",DOTA_TEAM_BADGUYS)
		end
	end	
end

--导入页面文件
function magicCanyouWar:OnGameRulesStateChange( keys )
	local state = GameRules:State_Get()


	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		--print("DOTA_GAMERULES_STATE_HERO_SELECTION")
		Timers:CreateTimer(60,function()
			for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
					--print(PlayerResource:GetSelectedHeroID(playerID))
					if PlayerResource:GetSelectedHeroID(playerID) == -1 then
							PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
					end
				end
			end
		end)
	end

	--时间结束没有选的话，随机英雄
	if state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			--if PlayerResource:GetPlayer(playerID) ~= nil and PlayerResource:IsValidPlayer(playerID) then
			if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
					--print(PlayerResource:GetSelectedHeroID(playerID))
					if PlayerResource:GetSelectedHeroID(playerID) == -1 then
							PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
					end
			end
        end
	end

	--进入游戏地图
	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		
		--运行检查商店进程
		initHero()--初始化英雄
		initMapStatus() -- 初始化地图数据
		initItemList() -- 初始化物品信息
		initPlayerPower() --初始化契约容器
		initTempPlayerPower()--初始化回合临时能力提升容器
		initContractList() --初始化契约信息
		initTalentList() --初始化天赋信息
		initMagicList()--初始化技能信息
		initShopStats()--初始化商店
		initSamsaraStone() --初始化轮回石
		Timers:CreateTimer(0,function ()
			gameProgress()--打开游戏流程的进程
		end)
	

	end
end



--整体弃用
--捡起物品监听
function magicCanyouWar:OnItemPickup (keys)
	--local unit = EntIndexToHScript(keys.dota_item_picked_up)
	local itemName = keys.itemname
	local playerID = keys.PlayerID
	local ItemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local HeroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	local playerTeam = HeroEntity:GetTeam()
end



