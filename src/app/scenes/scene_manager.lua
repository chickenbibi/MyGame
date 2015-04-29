SceneManager = SceneManager or BaseClass()

function SceneManager:__init()
	if SceneManager.Instance ~= nil then
	    error("SceneManager must be singleton!")
	end
	SceneManager.Instance = self

	self:ResetData()

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
	    return
	end
	for index = 1 , #self.scene_table do
		self:DeleteSceneFromMgr(self.scene_table[index])
	end
	return true
end