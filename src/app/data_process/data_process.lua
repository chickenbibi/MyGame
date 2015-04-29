
DataProcess = DataProcess or BaseClass()

function DataProcess:__init()
	if DataProcess.Instance ~= nil then
	    error("BattleScene must be singleton!")
	end
	DataProcess.Instance = self
	self:ResetData()
end

function DataProcess:ResetData()
	self.player_data_table = {}
	self.enemy_data_table = {}
	-- 每次增加角色之前自加一
	self.data_id = 0
end

function DataProcess:AddPlayer(role_id)
	self.data_id = self.data_id + 1
	local player_data = RoleData.New(role_id,self.data_id)
	table.insert(self.player_data_table,player_data)
	return player_data:GetAttr()
end

function DataProcess:AddEnemy(role_id)
	self.data_id = self.data_id + 1
	local enemy_data = RoleData.New(role_id,self.data_id)
	table.insert(self.enemy_data_table,enemy_data)
	return enemy_data:GetAttr()
end