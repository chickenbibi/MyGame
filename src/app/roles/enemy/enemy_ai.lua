--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		enemy_ai
Description: 	敌人的AI行为控制
Author: 		Luoheng
Email:			287429173@qq.com
]]
EnemyAI = EnemyAI or BaseClass(BaseRole)

function EnemyAI:__init()
	self.handle = {}
	self:AddMachineState()
end

function EnemyAI:AddMachineState()
	-- 基类事件
	local events = {
		{name = "patrol",  				from = "idle",    		to = "walking" },
		-- {name = "move_to_front",		from = "idle",			to = "walking"},
		-- {name = "move_to_back",  		from = "idle",    		to = "walking" },
		-- {name = "basic_attack",			from = "idle",			to = "attacking"},
	}
	-- 合并子类事件
	for k,v in pairs(events) do
		local index = #self.events
		self.events[index+1] = v
	end

	-- 基类事件回调
	local callbacks = {
        onpatrol	     		= handler(self, self.onPatrol),
	}
	-- 合并子类事件回调
	for k,v in pairs(callbacks) do
		self.callbacks[k] = v
	end
end

function EnemyAI:StartAI()
	print("StartAI !!!")
	self.dwell = {}
	self.dwell.x = self:GetPosition().x
	self.dwell.y = self:GetPosition().y

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	-- if not self.handle["patrol"] then
	-- 	self.handle["patrol"] = scheduler.scheduleGlobal(function() 
	-- 												   		self.fsm:doEvent("patrol") 
	-- 												    end,
	-- 												    5)
	-- end
	self.fsm:doEvent("patrol") 
	self.handle["sign_range"] = scheduler.scheduleGlobal(function()
															self:sign_range()
														end,
														CONFIG_SCHEDULER_RATE)
end

-- 巡逻
function EnemyAI:onPatrol()
	-- printf("Role_%d onPatroling !!!",self:GetRoleId())
	self:RandomSeed()
	local moveby_x = math.random(-self.__default_arg.patrol_range.x,self.__default_arg.patrol_range.x)
	local moveby_y = math.random(-self.__default_arg.patrol_range.y,self.__default_arg.patrol_range.y)

	local distance = math.sqrt(math.pow(moveby_x,2),math.pow(moveby_y,2))
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["stop"] then
		scheduler.unscheduleGlobal(self.handle["stop"])
		self.handle["stop"] = nil
	end
	self.handle["stop"] = scheduler.performWithDelayGlobal(	function()
																self.fsm:doEvent("stop")
																self.fsm:doEvent("patrol")
															end,
												 			distance / CONFIG_MOVE_PIX * CONFIG_MOVE_RATE)
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(moveby_x + self.dwell.x, moveby_y + self.dwell.y))
end

-- 视野判断
function EnemyAI:sign_range()
	local ret = DataProcess.Instance:GetRoleInRange(
													self:GetRoleId(),
													SceneManager.Instance:GetPlayerRoleId(),
													self.__default_arg.sign_range,
													true
													)
	if ret then
		-- 取消视野判断
		if self.handle["sign_range"] then
			local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
			scheduler.unscheduleGlobal(self.handle["sign_range"])
			self.handle["sign_range"] = nil
		end
		self:FocusOnPlayer()
	end
	return ret
end

function EnemyAI:FocusOnPlayer()
	print("Player is nearby , we should do something !!")
	DataProcess:SetFocus(self:GetRoleId(),true)

	-- 取消巡逻
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["stop"] then
		scheduler.unscheduleGlobal(self.handle["stop"])
		self.handle["stop"] = nil
	end

	self:RandomPattern()
end

function EnemyAI:RandomPattern()
	self:RandomSeed()
	if not self.__default_arg.attack_pattrn then
		return
	end
	local pattern = math.random(1,10000)
	for i,v in pairs(self.__default_arg.attack_pattrn) do
		if pattern <= v.rate then
			local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
			self.handle["attack_range"] = scheduler.scheduleGlobal(	function()
														self:AttackRange(v.skill_id)
													end,
													CONFIG_SCHEDULER_RATE)
			self:RandomMovePattern(v.skill_id)
		end
	end
end

function EnemyAI:RandomMovePattern(skill_id)
	self:RandomSeed()
	if not self.__default_arg.move_pattern then
		return
	end
	local pattern = math.random(1,10000)
	print("pattern = ",pattern)
	for k,v in pairs(self.__default_arg.move_pattern) do
		if pattern <= v.rate then
			self.move_pattern[v.name](skill_id)
			return
		end
	end
end

function EnemyAI:MoveToFront()
	print("MoveToFront")
end

function EnemyAI:MoveToBack(skill_id)
	print("MoveToBack")
	self:RandomSeed()

	local skill_config = self:GetSkillConfig(skill_id)
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	local pos = player:GetPosition()
	local offsetX = math.random(0,skill_config.range.x)
	local offsetY = math.random(0,skill_config.range.y)
	local distance = math.sqrt(math.pow(pos.x - offsetX - self:GetPosition().x,2),math.pow(pos.y - offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x - offsetX, pos.y - offsetY))

	self:FollowPlayer(skill_id)
end

function EnemyAI:MoveToAround(skill_id)
	self:RandomSeed()

	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	local pos = player:GetPosition()
	local vertical = self:GetPosition().y - pos.y
	if vertical > 0 then
	    vertical = 1
	else
		vertical = -1
	end
	local offsetX = math.random(CONFIG_AI_MOVE_X.min,CONFIG_AI_MOVE_X.max)
	local offsetY = math.random(CONFIG_AI_MOVE_Y.min,CONFIG_AI_MOVE_Y.max)
	local distance = math.sqrt(math.pow(pos.x + offsetX - self:GetPosition().x,2),math.pow(pos.y + offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x + offsetX, pos.y + offsetY))

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["MoveToAround"] then
		scheduler.unscheduleGlobal(self.handle["MoveToAround"])
		self.handle["MoveToAround"] = nil
	end
	self.handle["MoveToAround"] = scheduler.performWithDelayGlobal( function()
																		self:MoveToBack(skill_id)
																	end,
												 					distance / CONFIG_MOVE_PIX * CONFIG_MOVE_RATE)
end

function EnemyAI:FollowPlayer(skill_id)
	
end

-- 朝玩家靠近(近战型敌人)
-- function EnemyAI:MoveToPlayer()
-- 	if self:AttackRange() then
-- 		print("I should attack player !!!")
-- 		return
-- 	end
-- 	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
-- 	local player_pos = player:GetPosition()
-- 	local offsetX = math.random(-(player_pos.x - self:GetPosition().x) / 2,player_pos.x - self:GetPosition().x)
-- 	local offsetY = math.random(-(player_pos.y - self:GetPosition().y) / 2,player_pos.y - self:GetPosition().y)
-- 	local distance = math.sqrt(math.pow(offsetX,2),math.pow(offsetY,2))
-- 	local pos = {
-- 		x = self:GetPosition().x + offsetX,
-- 		y = self:GetPosition().y + offsetY,
-- 	}
-- 	DataProcess.Instance:MoveRole(self:GetRoleId(),pos)
-- 	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
-- 	scheduler.performWithDelayGlobal(function()
-- 									 	self:MoveToPlayer()	
-- 									 end,
-- 									 distance/CONFIG_MOVE_PIX)
-- end



-- 根据权值接近玩家
function EnemyAI:CloseToPlayerByWeight()
	self:RandomSeed()
	if not self.__default_arg.move_pattern then
		return
	end
	local move_pattern = math.random(1,10000)
	for i = 1, #self.__default_arg.move_pattern do
		if self.__default_arg.move_pattern[i] and self.__default_arg.move_pattern > move_pattern then
			self.fsm:doEvent(self.__default_arg.move_pattern[i].name)
			return
		end
	end
end

function EnemyAI:MoveToPlayer(move_pattern)
	
end

-- 到达攻击范围
function EnemyAI:AttackRange(skill_id)
	local skill_config = self:GetSkillConfig(skill_id)
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	local player_pos = player:GetPosition()
	local ret = DataProcess.Instance:GetRoleInRange(
													self:GetRoleId(),
													SceneManager.Instance:GetPlayerRoleId(),
													skill_config.range,
													true
													)
	if ret then
		local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
		scheduler.unscheduleGlobal(self.handle["attack_range"])
		self.handle["attack_range"] = nil
		self:Attack(skill_id)
	end
end

function EnemyAI:AttackByPattern(pattern)
end

function EnemyAI:GetSkillConfig(skill_id)
	return config_skill[skill_id]
end

function EnemyAI:Attack(skill_id)
	print("Attack !!!")
end

function EnemyAI:RandomSeed()
	math.randomseed(tostring(os.time() + self:GetRoleId() * 333 + 1):reverse():sub(1, 6))
end