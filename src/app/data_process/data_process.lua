--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		data_process
Description: 	数据处理中心，每次角色行为都将发送信息到此进行处理，然后返回场景管理器
Author: 		Luoheng
Email:			287429173@qq.com
]]
DataProcess = DataProcess or BaseClass()

function DataProcess:__init()
	if DataProcess.Instance ~= nil then
	    error("BattleScene must be singleton!")
	end
	DataProcess.Instance = self
	self:ResetData()
end

function DataProcess:ResetData()
	self.role_data_table = {}
	-- 每次增加角色之前自加一
	self.data_id = 0
end

function DataProcess:AddPlayer(role_id,pos)
	self.data_id = self.data_id + 1
	local player_data = RoleData.New(role_id,pos,self.data_id)
	table.insert(self.role_data_table,player_data)
	return player_data:GetAttr()
end

function DataProcess:AddEnemy(role_id,pos)
	self.data_id = self.data_id + 1
	local enemy_data = RoleData.New(role_id,pos,self.data_id)
	table.insert(self.role_data_table,enemy_data)
	return enemy_data:GetAttr()
end

function DataProcess:CastSkill(skill_id,role_id)
	local skill_range = self:GetSkillRange(skill_id)
	if not skill_range then
		return
	end
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	local target = self:GetRoleInRange(role_info,skill_range)
	self:CauseDamage(role_info,skill_id,target)
	self:CauseEffect(role_info,skill_id,target)
end

function DataProcess:CauseDamage(role_info,skill_id,target)
	if not target then
		return
	end
	local damage = 0
	for i = 1 , #target do
		damage = role_info:GetDamage() + self:GetSkillDamage(skill_id)
		if target[i]:DecreaseHp(damage) == 0 then
			self:NoticeDead(target[i])
		end
		printf("Role_%d 's cur HP is %d",target[i]:GetRoleId(),target[i]:GetHp())
	end
	self:NoticeDamage(target,damage)
end

function DataProcess:CauseEffect(role_info,skill_id,target)

end

function DataProcess:GetRoleInRange(role_info,skill_range)
	if not role_info or not skill_range or not self.role_data_table then
		return
	end
	local target = {}
	for i = 1 , #self.role_data_table do
		if self.role_data_table[i]:GetRoleType() ~= role_info:GetRoleType() then
			if math.abs(self.role_data_table[i]:GetPosition().x - role_info:GetPosition().x) <= skill_range.x and
			   self.role_data_table[i]:GetPosition().x * self.role_data_table[i]:GetDirection() >= role_info:GetPosition().x * self.role_data_table[i]:GetDirection() and
			   self.role_data_table[i]:GetPosition().y <= role_info:GetPosition().y + skill_range.y and 
			   self.role_data_table[i]:GetPosition().y >= role_info:GetPosition().y - skill_range.y 
			then
				table.insert(target,self.role_data_table[i])
			end
		end
	end
	return target
end

function DataProcess:GetSkillRange(skill_id)
	if not config_skill[skill_id] then
		return
	end
	return config_skill[skill_id].range
end

function DataProcess:GetSkillDamage(skill_id)
	if not skill_id or not config_skill[skill_id] then
		return
	end
	return config_skill[skill_id].damage
end

function DataProcess:GetRoleInfo(role_id)
	if not role_id or not self.role_data_table then
		return
	end
	for i = 1 , #self.role_data_table do
		if self.role_data_table[i]:GetRoleId() == role_id then
			return self.role_data_table[i]
		end
	end
end

function DataProcess:NoticeDamage(target,damage)
	if not target or not damage then
		return
	end
	SceneManager.Instance:NoticeDamage(target,damage)
end

function DataProcess:NoticeDead(role)
	SceneManager.Instance:NoticeDead(role)
	if not self.role_data_table then
		return
	end
	for i = 1 , #self.role_data_table do
		if self.role_data_table[i]:GetRoleId() == role:GetRoleId() then
			table.remove(self.role_data_table,i)
			return true
		end
	end
end