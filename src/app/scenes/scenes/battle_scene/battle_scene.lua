--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		battle_scene
Description: 	战斗场景类
Author: 		Luoheng
Email:			287429173@qq.com
]]
BattleScene = BattleScene or BaseClass(BaseScene)

function BattleScene:__init(scene_id)
	if BattleScene.Instance ~= nil then
	    error("BattleScene must be singleton!")
	end
	BattleScene.Instance = self

	local background = display.newSprite("res/scenes/background.png", display.cx, display.cy)
	self:GetScene():addChild(background)

	-- 添加角色
	self:AddRole()
end

function BattleScene:AddRole()
	self:AddPlayer(RoleType.Fighter,cc.p(display.cx -200,display.cy))
	self:AddEnemy(RoleType.Soldier, cc.p(display.cx + 300,display.cy - 100))
	self:AddEnemy(RoleType.Soldier, cc.p(display.cx + 300,display.cy + 100))
	self:AddEnemy(RoleType.Soldier, cc.p(display.cx + 400,display.cy))
end

function BattleScene:LoadSceneConfig()
	self.scene_config = self:GetSceneConfig("BattleScene")
end

-- function BattleScene:AddTouchLayer()
-- 	self.layerTouch = display.newLayer()
--     self.layerTouch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
--         self.player:onTouch(event.name)
--     end)
--     self.layerTouch:setLocalZOrder(CONFIG_ZORDER_UI)
--     self.layerTouch:setTouchEnabled(true)
--     self.layerTouch:setTouchSwallowEnabled(true)
--     self.layerTouch:setPosition(cc.p(0,0))
--     self.layerTouch:setContentSize(cc.size(display.width, display.height))
--     self:addChild(self.layerTouch)
-- end

function BattleScene:StartEnemyAI()
	if not self.role_table then
		return
	end
	for i = 1, #self.role_table do
		if self.role_table[i].StartAI then
			self.role_table[i]:StartAI()
		end
	end
end