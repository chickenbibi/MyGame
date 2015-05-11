--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		scene_manager
Description: 	场景管理器；所有场景的初始化均在此进行，注意场景接口的保持
Author: 		Luoheng
Email:			287429173@qq.com
]]
SceneManager = SceneManager or BaseClass()

function SceneManager:__init()
	if SceneManager.Instance ~= nil then
	    error("SceneManager must be singleton!")
	end
	SceneManager.Instance = self
	self:ResetData()

	-- 摇杆初始化
	StickUnits.New()

	-- 场景初始化
	GameStartScene.new()
	BattleScene.new()

	self:AddSceneToMgr(GameStartScene.Instance)
	self:AddSceneToMgr(BattleScene.Instance)
end

function SceneManager:AddSceneToMgr(scene)
	if not scene or not self.scene_table then
	    return
	end
	scene:retain()
	table.insert(self.scene_table,scene)
	return true
end

function SceneManager:DeleteSceneFromMgr(scene)
	if not scene or not self.scene_table or #self.scene_table == 0 then
	    printError("Scene [%d] Delete Fail !!!",index)
	    return
	end
	for index = 1 , #self.scene_table do
		if self.scene_table[index] == scene then
		    table.remove(self.scene_table,index)
		    scene:release()
		    return true
		end
	end
end

function SceneManager:ResetData()
	if not self.scene_table or #self.scene_table == 0 then
		self.scene_table = {}
		self.cur_scene = nil
	    return
	end
	for index = 1 , #self.scene_table do
		self:DeleteSceneFromMgr(self.scene_table[index])
	end
	return true
end

function SceneManager:EnterScene(scene)
	self.cur_scene = scene
	StickUnits.Instance:RemoveFromScene()
	StickUnits.Instance:AddToScene(scene:GetTouchLayer())
	display.replaceScene(scene)
end

function SceneManager:UpdateRoleAttr(target)
	if not target then
		return
	end
	local scene_role_table = self.cur_scene:GetRoleTable()
	local target_role_table = {}
	for i = 1 , #target do
		for j = 1 , #scene_role_table do
			if scene_role_table[j]:GetRoleId() == target[i]:GetRoleId() then
				scene_role_table[j]:InitAttribute(target[i]:GetAttr())
				table.insert(target_role_table,scene_role_table[j])
				break
			end
		end
	end
	return target_role_table
end

function SceneManager:NoticeDead(role)
	if not role then
		return
	end
	local dead_role = self:GetRoleById(role:GetRoleId())
	if dead_role then
		dead_role:ToDead()
		self.cur_scene:RemoveRoleFromTable(dead_role)
	end
end

function SceneManager:GetRoleById(role_id)
	if not role_id then
	    return
	end
	local scene_role_table = self.cur_scene:GetRoleTable()
	for j = 1 , #scene_role_table do
		if scene_role_table[j]:GetRoleId() == role_id then
			return scene_role_table[j]
		end
	end
end

function SceneManager:NoticeDamage(target, damage)
	if not target or not damage then
		return
	end
	local target_role_table = self:UpdateRoleAttr(target)
	if not target_role_table then
		return
	end
	for i = 1 , #target_role_table do
		target_role_table[i]:DecreaseHp(damage)
	end
end

function SceneManager:SetPlayerRoleId(RoleId)
	self.player_role_id = RoleId
end

function SceneManager:GetPlayerRoleId()
	return self.player_role_id
end

function SceneManager:SetRolePosition(role_id,pos)
	local role = self:GetRoleById(role_id)
	if role then
	    role:MoveToPosition(pos)
	end
end

function SceneManager:TurnRoleAround(role_id)
	local role = self:GetRoleById(role_id)
	if not role then
	    return
	end
	role:TurnAround()
end