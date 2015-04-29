BaseRole = BaseRole or BaseClass()

function BaseRole:__init(attr,events,callbacks)
	self:InitAttribute(attr)
	self:InitBaseStateMachine(events,callbacks)
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
		{name = "start",  	from = "none",    to = "idle" },
		{name = "walk",  	from = "idle",    to = "is_walking" },
		{name = "attack",  	from = "idle",    to = "is_attacking" },
		{name = "stay",		from = "*",		  to = "is_staying" },
		{name = "kill",		from = "*",		  to = "is_dead" },
	}
	-- 合并子类事件
	table.insertto(self.events, checktable(events))

	-- 基类事件回调
	self.callbacks = {
        onstart       	= handler(self, self.onStart),
        onwalk        	= handler(self, self.onWalk),
        onattack       	= handler(self, self.onAttack),
        onstay      	= handler(self, self.onStay),
        onkill        	= handler(self, self.onKill),
	}
	-- 合并子类事件回调
	table.insertto(self.callbacks, checktable(callbacks))

	-- 绑定状态机
	self:addComponent("components.behavior.StateMachine")
	-- 取得状态机
	self.fsm = self:getComponent("components.behavior.StateMachine")
	-- 启动状态机
	self.fsm:setupState(
		{
			events = self.events,
          	callbacks = self.callbacks
        }
    )
    self.fsm:doEvent("start")
end

function BaseRole:onStart()
	self:dispatchEvent({name = SCENE_EVENT.ROLE_INIT})
end

function BaseRole:onWalk()
end

function BaseRole:onAttack()
end

function BaseRole:onStay()
end

function BaseRole:onKill()
end