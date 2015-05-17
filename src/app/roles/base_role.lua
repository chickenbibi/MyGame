--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		fighter
Description: 	角色行为基类
Author: 		Luoheng
Email:			287429173@qq.com
]]
BaseRole = BaseRole or BaseClass()

function BaseRole:__init(attr)
	self:InitAttribute(attr)
	self:InitBaseStateMachine()
	self:InitSprite(self.__default_arg.sprite_name)
end

-- 设置属性
function BaseRole:InitAttribute(attr)
	if DEBUG_ROLE_INIT == 1 then
	    printf("[BaseRole:InitAttribute %s]",tostring(attr))
	end

	if attr then
		self.attr = {}
		for key, value in pairs(attr) do
			self.attr[key] = value
		end 
	end
end

function BaseRole:InitBaseStateMachine()
	-- 基类事件
	self.events = {
		{name = "start",  		from = "none",    							to = "idle" },
		{name = "walk",			from = "idle",								to = "walking"},
		{name = "attack",  		from = "idle",    							to = "attacking" },
		{name = "stop",			from = {"walking","attacking","hitted"},	to = "idle"},
		{name = "hit",			from = "*",									to = "hitted"},
	}

	-- 基类事件回调
	self.callbacks = {
        onstart       		= handler(self, self.onStart),
        onwalking			= handler(self, self.onWalking),
        onattacking 		= handler(self, self.onAttacking),
        onstop	     		= handler(self, self.onStop),
        onhitted 			= handler(self, self.onHitted),
	}
end

function BaseRole:SetupStateMachine()
	self.fsm = {}
    cc.GameObject.extend(self.fsm)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()

	-- 启动状态机
	self.fsm:setupState(
		{
			events = self.events,
          	callbacks = self.callbacks
        }
    )
    self.fsm:doEvent("start")
end

function BaseRole:InitSprite(sprite_name)
	cc.FileUtils:getInstance():addSearchPath("res/roles/")
	self.sprite = display.newSprite(sprite_name)
end

function BaseRole:AddToScene(scene,role)
	if not self.sprite then
	    error("Can't Find the sprite !!!")
	end
	self.sprite:setPosition(cc.p(role:GetPosition().x + self.__default_arg.pos_offset.x,role:GetPosition().y + self.__default_arg.pos_offset.y))
	self.sprite:setLocalZOrder(CONFIG_ZORDER_ROLE-role:GetPosition().y+600)
	scene:addChild(self.sprite)
end

function BaseRole:onStart()
	-- self.fsm:dispatchEvent({name = SCENE_EVENT.ROLE_INIT})
end

function BaseRole:onafterWalk()
end

function BaseRole:onAttacking(skill_id)
	if not self:GetSkillConfig(skill_id) then
		skill_id = 100
	end
	local func = function()
		DataProcess.Instance:CastSkill(self:GetRoleId(),skill_id)
		if not self.fsm:isState("idle") then
			self.fsm:doEvent("stop")
		end
	end
	self:PlayAnimationOnce("attack",func)
end

function BaseRole:onStop()
	DataProcess.Instance:StopRole(self:GetRoleId())
	transition.stopTarget(self.sprite)
	local sprite_name = string.split(self.__default_arg.sprite_name, "#")
	self.sprite:setSpriteFrame(display.newSpriteFrame(sprite_name[2]))
end

function BaseRole:GetRoleId()
	return self.attr.role_id
end

function BaseRole:GetPosition()
	return self.attr.pos
end

function BaseRole:GetDirection()
	return self.attr.direction
end

function BaseRole:onWalking()
	self:PlayAnimationForever("walk")
end

function BaseRole:onleaveWalking()
	self:onStop()
end

function BaseRole:DecreaseHp(damage)
	if not damage then
		return
	end
	if self.attr.hp <= damage then
		self.attr.hp = 0
	end
	self.attr.hp = self.attr.hp - damage

	-- HP减少特效
	self.fsm:doEvent("hit")
end

function BaseRole:onHitted()
	local func = function()
		self.fsm:doEvent("stop")
	end
	self:PlayAnimationOnce("hit",func)
end

function BaseRole:PlayAnimationOnce(action,func)
	local str = string.split(self.__default_arg.sprite_name, "#")
	local name = string.split(str[2], "-")
	transition.playAnimationOnce(self.sprite, display.getAnimationCache(name[1].."-"..action),nil,func)
end

function BaseRole:PlayAnimationForever(action)
	local str = string.split(self.__default_arg.sprite_name, "#")
	local name = string.split(str[2], "-")
	transition.playAnimationForever(self.sprite, display.getAnimationCache(name[1].."-"..action))
end

function BaseRole:ToDead()
end

function BaseRole:MoveToPosition(pos)
	if not pos then
	    return
	end
	self.attr.pos = pos
	self.sprite:setPosition(cc.p(pos.x + self.__default_arg.pos_offset.x,pos.y + self.__default_arg.pos_offset.y))
	self.sprite:setLocalZOrder(CONFIG_ZORDER_ROLE-pos.y+600)
end

function BaseRole:TurnAround()
	
end

function BaseRole:GetSkillConfig(skill_id)
	return config_skill[skill_id]
end