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
	self.dwell = {}
	self.dwell.x = self:GetPosition().x
	self.dwell.y = self:GetPosition().y

	self.fsm:doEvent("patrol") 
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["sign_range"] then
		scheduler.unscheduleGlobal(self.handle["sign_range"])
		self.handle["sign_range"] = nil
	end
	self.handle["sign_range"] = scheduler.scheduleGlobal(function()
															self:SignRange()
														end,
														CONFIG_SCHEDULER_RATE)
end

-- 巡逻
function EnemyAI:onPatrol()
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
function EnemyAI:SignRange()
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
		if not self.fsm:isState("idle") then
			self.fsm:doEvent("stop")
		end
		self:FocusOnPlayer()
	end
end

function EnemyAI:FocusOnPlayer()
	DataProcess.Instance:SetFocus(self:GetRoleId(),true)

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

	if not self.fsm:isState("idle") then
		self.fsm:doEvent("stop")
	end
	local pattern = math.random(1,10000)
	for k,v in pairs(self.__default_arg.pattern) do
		if pattern <= v.rate then
			local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
			if self.handle["random_pattern"] then
				scheduler.unscheduleGlobal(self.handle["random_pattern"])
				self.handle["random_pattern"] = nil
			end
			self.handle["random_pattern"] = scheduler.performWithDelayGlobal(function()
																				self.pattern[v.action](v.range)
																			end,
																	 		1)
			return
		end
	end
end

function EnemyAI:RandomAttackPattern()
	self:RandomSeed()
	local skill_id = 100
	local pattern = math.random(1,10000)
	for k,v in pairs(self.__default_arg.attack_pattrn) do
		if pattern <= v.rate then
			local range = self:GetSkillConfig(v.skill_id).range
			self:RandomMovePattern(range)
			skill_id = v.skill_id
		end
	end

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["attack_range"] then
		scheduler.unscheduleGlobal(self.handle["attack_range"])
		self.handle["attack_range"] = nil
	end
	self.handle["attack_range"] = scheduler.scheduleGlobal( function()
																self:AttackRange(skill_id)
															end,
															0.2)
end

function EnemyAI:RandomMovePattern(range)
	self:RandomSeed()
	if self.fsm:canDoEvent("walk") then
		self.fsm:doEvent("walk")
	else
		self:RandomPattern()
	end
	if not self.__default_arg.move_pattern then
		return
	end
	local pattern = math.random(1,10000)
	for k,v in pairs(self.__default_arg.move_pattern) do
		if pattern <= v.rate then
			self.move_pattern[v.action](range)
			return
		end
	end
end

function EnemyAI:MoveToAround(range)
	self:RandomSeed()

	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	if not player then
	    self:StopAI()
	end
	local pos = player:GetPosition()
	local vertical = math.random(-10000,10000)
	if vertical > 0 then
	    vertical = 1
	else
		vertical = -1
	end
	local offsetX = math.random(-range.x,range.x)
	local offsetY = math.random(range.y,range.y+100) * vertical
	local distance = math.sqrt(math.pow(pos.x + offsetX - self:GetPosition().x,2),math.pow(pos.y + offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x + offsetX, pos.y + offsetY))

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["MoveToAround"] then
		scheduler.unscheduleGlobal(self.handle["MoveToAround"])
		self.handle["MoveToAround"] = nil
	end
	local move_pattern = math.random(0,10000)
	local func = handler(self, self.MoveToBack)
	if move_pattern <= 5000 then
		func = handler(self, self.MoveToFront)
	end

	self.handle["MoveToAround"] = scheduler.performWithDelayGlobal( function()
																		func(range)
																	end,
												 					distance / CONFIG_MOVE_PIX * CONFIG_MOVE_RATE)
end

function EnemyAI:MoveToFront(range)
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	if not player then
	    self:StopAI()
	end
	local pos = player:GetPosition()
	local offsetX = math.random(range.x,range.x + 100)
	local offsetY = math.random(-range.y,range.y)
	local distance = math.sqrt(math.pow(pos.x + offsetX - self:GetPosition().x,2),math.pow(pos.y - offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x + offsetX, pos.y - offsetY))

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["MoveToFront"] then
		scheduler.unscheduleGlobal(self.handle["MoveToFront"])
		self.handle["MoveToFront"] = nil
	end
	self.handle["MoveToFront"] = scheduler.performWithDelayGlobal( function()
																		self:FollowPlayer(range)
																	end,
												 					distance / CONFIG_MOVE_PIX * CONFIG_MOVE_RATE)
end

function EnemyAI:MoveToBack(range)
	self:RandomSeed()

	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	if not player then
	    self:StopAI()
	end
	local pos = player:GetPosition()
	local offsetX = math.random(range.x,range.x+100)
	local offsetY = math.random(-range.y,range.y)
	local distance = math.sqrt(math.pow(pos.x - offsetX - self:GetPosition().x,2),math.pow(pos.y - offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x - offsetX, pos.y - offsetY))

	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.handle["MoveToBack"] then
		scheduler.unscheduleGlobal(self.handle["MoveToBack"])
		self.handle["MoveToBack"] = nil
	end
	self.handle["MoveToBack"] = scheduler.performWithDelayGlobal( function()
																		self:FollowPlayer(range)
																	end,
												 					distance / CONFIG_MOVE_PIX * CONFIG_MOVE_RATE)
end

function EnemyAI:FollowPlayer(range)
	self:RandomSeed()

	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	if not player then
	    self:StopAI()
	end
	local pos = player:GetPosition()
	local vertical = self:GetPosition().y - pos.y
	if vertical > 0 then
	    vertical = 1
	else
		vertical = -1
	end

	local offsetX = nil
	local offsetY = nil

	offsetX = math.random(0,range.x) * vertical
	offsetY = math.random(-range.y,range.y)
	
	local distance = math.sqrt(math.pow(pos.x + offsetX - self:GetPosition().x,2),math.pow(pos.y + offsetY - self:GetPosition().y,2))
	DataProcess.Instance:MoveRole(self:GetRoleId(),cc.p(pos.x + offsetX, pos.y + offsetY))

	self:RandomPattern()
end

-- 到达攻击范围
function EnemyAI:AttackRange(skill_id)
	local skill_config = self:GetSkillConfig(skill_id)
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	if not player then
	    self:StopAI()
	end
	local player_pos = player:GetPosition()
	local ret = DataProcess.Instance:GetRoleInRange(
													self:GetRoleId(),
													SceneManager.Instance:GetPlayerRoleId(),
													skill_config.range
													)
	if ret then
		local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
		scheduler.unscheduleGlobal(self.handle["attack_range"])
		self.handle["attack_range"] = nil
		self:Attack(skill_id)
	end
end

function EnemyAI:Attack(skill_id)

	if not self.fsm:isState("idle") then
		self.fsm:doEvent("stop")
	end
	self.fsm:doEvent("attack")
	-- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	-- if self.handle["attack_range"] then
	-- 	scheduler.unscheduleGlobal(self.handle["attack_range"])
	-- 	self.handle["attack_range"] = nil
	-- end
end

function EnemyAI:onAttacking()
	local skill_id = 100
	local func = function()
		DataProcess.Instance:CastSkill(self:GetRoleId(),skill_id)
		self:StopAI()
		self:StartAI()
	end
	self:PlayAnimationOnce("attack",func)
end

function EnemyAI:GetSkillConfig(skill_id)
	return config_skill[skill_id]
end

function EnemyAI:RandomSeed()
	local random_seed = 0
	for index = 1,10 do
		random_seed = math.random(1,10000)
	end
	math.randomseed(tostring(os.time() + self:GetRoleId() * 333 + random_seed):reverse():sub(1, 6))
end

function EnemyAI:StopAI()
	if self.fsm:canDoEvent("stop") then
		self.fsm:doEvent("stop")
	end
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	for k,v in pairs(self.handle) do
		if v then
			scheduler.unscheduleGlobal(v)
			v = nil
		end
	end

end

function EnemyAI:onHitted()
	local func = function()
		self:StartAI()
	end
	self:StopAI()
	self:PlayAnimationOnce("hit",func)
end

function BaseRole:ToDead()
	self:StopAI()
	self.fsm:doEvent("killed")
end

function BaseRole:onDead()
	-- 死亡动作
	local func = function()
		transition.fadeTo(self.sprite, 
							{opacity = 0, 
							 time = 2, 
							 onComplete = function() 
							 				self.sprite:removeFromParent()
							 				self:DeleteMe()
							 			  end
							}
						 )
	end
	self:PlayAnimationOnce("dead",func)
end

function EnemyAI:TurnAround()
	if self:GetDirection() == -1 then
		self.sprite:setAnchorPoint(cc.p(0.65,0.5))
		self.sprite:setFlippedX(false)
	else
		self.sprite:setAnchorPoint(cc.p(0.35,0.5))
		self.sprite:setFlippedX(true)
	end
end