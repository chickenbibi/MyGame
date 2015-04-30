RoleData = RoleData or BaseClass()

function RoleData:__init(player_id,index)
	self:ResetData(index)
	self:LoadConfigData(player_id)
end

function RoleData:ResetData(index)
	self.attr = {}
	self.attr.hp = 0
	self.attr.level = 1
	-- 数据索引，角色数据唯一标识
	self.attr.data_id = index
end

function RoleData:LoadConfigData(player_id)
	if not player_id or not config_role[player_id] then
		error("Don't Have This Config Of Role !!!")
		return
	end
	for key, value in pairs(config_role[player_id]) do
		self.attr[key] = value
	end
	self.attr.hp = self.attr.base_hp + self.attr.grow_hp * self.attr.level
end

function RoleData:GetAttr()
	return self.attr
end

function RoleData:GetHp()
	return self.attr.hp
end