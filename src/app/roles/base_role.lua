BaseRole = BaseRole or BaseClass()

function BaseRole:__init()
	-- 基类属性
	if CONFIG_PROPERTIES.BASE_ROLE then
		self.properties = {}
		for key, value in pairs(CONFIG_PROPERTIES.BASE_ROLE) do
			self.properties[key] = value
			print(key)
			print(value)
		end
	end
	-- 基类事件
	self.events = {
		{name = "start",  	from = "none",    to = "idle" },
		{name = "walk",  	from = "idle",    to = "is_walking" },
		{name = "attack",  	from = "idle",    to = "is_attacking" },
		{name = "stay",		from = "*",		  to = "is_staying" },
		{name = "kill",		from = "*",		  to = "is_dead" },
	}
	-- 基类事件回调
	self.callbacks = {
        onstart       	= handler(self, self.onStart),
        onwalk        	= handler(self, self.onWalk),
        onattack       	= handler(self, self.onAttack),
        onstay      	= handler(self, self.onStay),
        onkill        	= handler(self, self.onKill),
	}


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