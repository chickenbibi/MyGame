--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		fighter
Description: 	角色行为基类
Author: 		Luoheng
Email:			287429173@qq.com
]]
BaseScene = BaseScene or BaseClass()

function BaseScene:__init(scene_id)
	local scene_config = self:GetSceneConfig(scene_id)
	if not scene_config then
	    error("Doesn't Exsit the Scene config")
	end

	self.scene = display.newScene(tostring(scene_id))
	self.scene:retain()

	self:ResetRoleTable()
	if self.loadJsonCallBack then
	    self:loadJsonCallBack()
	end
end

function BaseScene:GetScene()
	return self.scene
end

function BaseScene:ResetRoleTable()
	self.role_table = {}
end

function BaseScene:AddRoleToTable(role)
	if not role then
		return
	end
	table.insert(self.role_table,role)
end

function BaseScene:GetRoleTable()
	return self.role_table
end

function BaseScene:RemoveRoleFromTable(role)
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

function BaseScene:GetSceneConfig(scene_id)
	return config_scene[scene_id]
end

function BaseScene:AddPlayer(role_type,pos)
	if role_type == FighterType then
		local player_attr = DataProcess.Instance:AddPlayer(role_type,pos)
		if player_attr then
		    self.player = Fighter.New(player_attr)
		    self.player:AddToScene(self,self.player)
		    self:AddRoleToTable(self.player)
		    SceneManager.Instance:SetPlayerRoleId(self.player:GetRoleId())
		end
	end
end

function BaseScene:AddEnemy(role_type, pos)
	if role_type == SoldierType then
	    local enemy_attr = DataProcess.Instance:AddEnemy(role_type,pos)
	    if enemy_attr then
	        enemy = Soldier.New(enemy_attr)
	        enemy:AddToScene(self,enemy)
	        self:AddRoleToTable(enemy)
	    end
	end
end

function BaseScene:StartEnemyAI()
	if not self.role_table then
		return
	end
	for i = 1, #self.role_table do
		if self.role_table[i].StartAI then
			self.role_table[i]:StartAI()
		end
	end
end

function BaseScene:SetNextScene(scene)
	self.next_scene = scene
end

function BaseScene:EnterNextScene()
	SceneManager.Instance:EnterScene(self.next_scene)
end