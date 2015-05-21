--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		battle_scene
Description: 	战斗场景类
Author: 		Luoheng
Email:			287429173@qq.com
]]
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
	self:ResetRoleTable()
	-- 添加角色
	local pos = cc.p(display.cx -200,display.cy)
	self:AddPlayer(100,pos)
	pos = cc.p(display.cx + 300,display.cy - 100)
	self:AddEnemy(1000,pos)
	pos = cc.p(display.cx + 300,display.cy + 100)
	self:AddEnemy(1000,pos)
	pos = cc.p(display.cx + 400,display.cy)
	self:AddEnemy(1000,pos)
	-- 添加触摸层
	self:AddTouchLayer()
end

function BattleScene:AddTouchLayer()
	self.layerTouch = display.newLayer()
    self.layerTouch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.player:onTouch(event.name)
    end)
    self.layerTouch:setLocalZOrder(CONFIG_ZORDER_UI)
    self.layerTouch:setTouchEnabled(true)
    self.layerTouch:setTouchSwallowEnabled(true)
    self.layerTouch:setPosition(cc.p(0,0))
    self.layerTouch:setContentSize(cc.size(display.width, display.height))
    self:addChild(self.layerTouch)
end

function BattleScene:GetTouchLayer()
	return self.layerTouch
end

function BattleScene:ResetRoleTable()
	self.role_table = {}
end

function BattleScene:AddPlayer(role_type,pos)
	local player_attr = DataProcess.Instance:AddPlayer(role_type,pos)
	if player_attr then
	    self.player = Fighter.New(player_attr)
	    self.player:AddToScene(self,self.player)
	    self:AddRoleToTable(self.player)
	    SceneManager.Instance:SetPlayerRoleId(self.player:GetRoleId())
	end
end

function BattleScene:AddEnemy(role_type, pos)
	local enemy_attr = DataProcess.Instance:AddEnemy(role_type,pos)
	if enemy_attr then
	    enemy = Soldier.New(enemy_attr)
	    enemy:AddToScene(self,enemy)
	    self:AddRoleToTable(enemy)
	end
end

function BattleScene:AddRoleToTable(role)
	if not role then
		return
	end
	table.insert(self.role_table,role)
end

function BattleScene:RemoveRoleFromTable(role)
	if not role then
		return
	end

	for index = 1 , #self.role_table do
		if role:GetRoleId() == self.role_table[index]:GetRoleId() then
		    table.remove(self.role_table,index)
		    return
		end
	end
end

function BattleScene:GetRoleTable()
	return self.role_table
end

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