BattleScene = BattleScene or class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor()
	if BattleScene.Instance ~= nil then
	    error("BattleScene must be singleton!")
	end
	BattleScene.Instance = self
	local background = display.newSprite("res/scenes/background.png", display.cx, display.cy)
	self:addChild(background)

	-- 重置场景角色表
	self:ResetRoleSceneTable()
	-- 添加角色
	self:AddPlayer(100)
	-- 添加触摸层
	self:AddTouchLayer()
end

function BattleScene:AddTouchLayer()
	self.layerTouch = display.newLayer()
    self.layerTouch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.player:onTouch(event.name)
    end)
    self.layerTouch:setTouchEnabled(true)
    self.layerTouch:setPosition(cc.p(0,0))
    self.layerTouch:setContentSize(cc.size(display.width, display.height))
    self:addChild(self.layerTouch)
end

function BattleScene:ResetRoleSceneTable()
	self.role_scene_table = {}
end

function BattleScene:AddPlayer(role_id)
	local player_attr = DataProcess.Instance:AddPlayer(role_id)
	if player_attr then
	    self.player = Fighter.New(player_attr)
	    self.player:AddToScene(self,cc.p(display.left + 200, display.cy))
	end
end

function BattleScene:AddRoleToSceneTable(role)
	if role == nil then
		return
	end
	table.insert(self.role_scene_table,role)
end

function BattleScene:RemoveRoleFromSceneTable(role)
	if role == nil then
		return
	end

	for index = 1 , #self.role_scene_table do
		if role.id_ == self.role_scene_table[index].id_ then
		    table.remove(self.role_scene_table,index)
		end
	end
end
