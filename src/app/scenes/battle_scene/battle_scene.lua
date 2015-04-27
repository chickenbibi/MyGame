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
end

function BattleScene:ResetRoleSceneTable()
	self.role_scene_table = {}
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
