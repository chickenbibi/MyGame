--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		base_role
Description: 	游戏角色(包括玩家和敌人)行为基类
Author: 		Luoheng
Email:			287429173@qq.com
]]
BaseRole = BaseRole or BaseClass()

function BaseRole:__init(attr,default)
	self:InitAttribute(attr)
	self:InitBaseStateMachine(default.events,default.callbacks)
	self:InitSprite(default.sprite_name)
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

function BaseRole:InitBaseStateMachine(events,callbacks)
	-- 基类事件
	self.events = {
		{name = "start",  	from = "none",    						to = "idle" },
		{name = "walk",  	from = "idle",   		 				to = "is_walking" },
		{name = "attack",  	from = "idle",    						to = "is_attacking" },
		{name = "kill",		from = "*",		  						to = "is_dead" },
		{name = "backidle",		from = {"is_walking","is_attacking"},	to = "idle"},
	}
	-- 合并子类事件
	table.insertto(self.events, checktable(events))

	-- 基类事件回调
	self.callbacks = {
        onstart       	= handler(self, self.onStart),
        onwalk        	= handler(self, self.onWalk),
        onattack       	= handler(self, self.onAttack),
        onkill        	= handler(self, self.onKill),
        onbackidle     	= handler(self, self.onbackidle),
	}
	-- 合并子类事件回调
	table.insertto(self.callbacks, checktable(callbacks))

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

function BaseRole:AddToScene(scene,pos)
	if not self.sprite then
	    error("Can't Find the sprite !!!")
	end
	self.sprite:setPosition(pos)
	scene:addChild(self.sprite)
end

function BaseRole:onStart()
	-- self.fsm:dispatchEvent({name = SCENE_EVENT.ROLE_INIT})
end

function BaseRole:onWalk()
end

function BaseRole:onAttack()
end

function BaseRole:onKill()
end

function BaseRole:onbackidle()
	print("onidle !!!")
end
