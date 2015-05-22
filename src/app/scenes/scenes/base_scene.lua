--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		base_scene
Description: 	场景管理器基类
Author: 		Luoheng
Email:			287429173@qq.com
]]
BaseScene = BaseScene or BaseClass()

function BaseScene:__init()
	self.scene = display.newScene(tostring(self))
	self.scene:retain()
	self:ResetRoleTable()
	self:LoadSceneConfig()
end

function BaseScene:LoadSceneConfig()
    error("Doesn't Exsit the Method:[LoadSceneConfig] !!")
end

function BaseScene:__delete()
	self.scene:release()
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
	if role_type == RoleType.Fighter then
		local player_attr = DataProcess.Instance:AddPlayer(role_type,pos)
		if player_attr then
		    self.player = Fighter.New(player_attr)
		    self.player:AddToScene(self:GetScene(),self.player)
		    self:AddRoleToTable(self.player)
		    SceneManager.Instance:SetPlayerRoleId(self.player:GetRoleId())
		end
	end
end

function BaseScene:AddEnemy(role_type, pos)
	if role_type == RoleType.Soldier then
	    local enemy_attr = DataProcess.Instance:AddEnemy(role_type,pos)
	    if enemy_attr then
	        enemy = Soldier.New(enemy_attr)
	        enemy:AddToScene(self:GetScene(),enemy)
	        self:AddRoleToTable(enemy)
	    end
	end
end

function BaseScene:AddStick()
	
end

function BaseScene:AddQuickSkill()
	
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

function BaseScene:SetNextScene(scene_mgr)
	self.next_scene_mgr = scene_mgr
end

function BaseScene:EnterNextScene()
	SceneManager.Instance:EnterScene(self.next_scene_mgr)
end