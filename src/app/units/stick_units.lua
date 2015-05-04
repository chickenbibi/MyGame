PIX_RATE = 5

StickUnits = StickUnits or BaseClass()

function StickUnits:__init()
	if StickUnits.Instance ~= nil then
	    error("StickUnits must be singleton!")
	end
	StickUnits.Instance = self
	self.round_r = 88.5
	self:InitSprite()
	self:InitEvents()
end

function StickUnits:InitSprite()
	self.background = display.newSprite("res/units/stick/stick_bg.png", display.left + self.round_r, display.bottom + self.round_r)
	self.background:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:setOpacity(255)
	self.stick = display.newSprite("res/units/stick/stick.png", self.round_r, self.round_r)
	self.stick:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:addChild(self.stick)
	self.background:retain()
	self.stick:retain()
end

function StickUnits:InitEvents()
	self.background:setTouchEnabled(true)
	self.background:setTouchSwallowEnabled(true)
	self.background:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self.background:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) return true end)
	self.background:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event) self:TouchEventCallBack(event) end)
end

function StickUnits:AddToScene(layer)
	layer:addChild(self.background)
end

function StickUnits:RemoveFromScene()
	if self.background and self.background:getParent() then
		self.background:removeFromParent()
	end
end

function StickUnits:TouchEventCallBack(event)
	if event.name == "began" then
		print("began")
		-- local x,y = self:GetStickPosition(event.x,event.y)
  --   	self.stick:setPosition(cc.p(self.round_r + x,self.round_r + y))
		-- self:TouchScheduler(event.x,event.y)
		-- transition.fadeTo(self.background, { opacity = 255, time = 1})
    elseif event.name == "moved" then
    	print("moved")
    	local x,y = self:GetStickPosition(event.x,event.y)
    	self.stick:setPosition(cc.p(x,y))

    	-- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    	-- self.handle = scheduler.scheduleGlobal(self:TouchScheduler(event.x,event.y), 1)
	    return true

	elseif event.name == "ended" then
		print("ended")
	    return false

	elseif event.name == "cancelled" then
		print("cancelled")
		return false
    end
end

function StickUnits:GetStickPosition(event_x,event_y)
	local x = (event_x - self.round_r) or self.round_r
	local y = (event_y - self.round_r) or self.round_r
	-- 斜边长度
	local xie = math.sqrt(math.pow((event_x - self.round_r), 2) + math.pow((event_y - self.round_r), 2))
	cosAngle = (event_x - self.round_r) / xie
	sinAngle = (event_y - self.round_r) / xie
	if xie > self.round_r then
	    x = self.round_r*cosAngle
	    y = self.round_r*sinAngle
	end
	return x,y
end

function StickUnits:TouchScheduler(event_x,event_y)
	if not SceneManager.Instance:GetPlayerRoleId() then
	    return
	end
	local moveby_x,moveby_y = self:GetStickPosition(event_x,event_y)
	moveby_x = PIX_RATE * moveby_x / self.round_r
	moveby_y = PIX_RATE * moveby_y / self.round_r
	local player_cur_pos = DataProcess.Instance:GetRoleInfo(SceneManager.Instance:GetPlayerRoleId()):GetPosition()
	player_cur_pos.x = player_cur_pos.x + moveby_x
	player_cur_pos.y = player_cur_pos.y + moveby_y
	DataProcess.Instance:MoveRole(SceneManager.Instance:GetPlayerRoleId(),player_cur_pos)
end