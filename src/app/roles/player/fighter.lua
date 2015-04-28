Fighter = Fighter or BaseClass(BaseRole)

function Fighter:__init()
	-- fighter类属性
	self:SetProperties()

	-- 设置状态机
	self:SetUpState()
end

function SetProperties()
	if CONFIG_PROPERTIES.FIGHTER then
		for key, value in pairs(CONFIG_PROPERTIES.FIGHTER) do
			self.properties[key] = value
			print(key)
			print(value)
		end
	end
end

function Fighter:SetUpState()
	-- fighter类独有事件
	local events = {
	}
	-- 合并fighter和基类事件
	table.insertto(self.events, checktable(events))
	-- fighter类独有事件回调
	local callbacks = {
	}
	table.insertto(self.callbacks, checktable(callbacks))

	-- 绑定状态机
	self:addComponent("components.behavior.StateMachine"):exportMethods()
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