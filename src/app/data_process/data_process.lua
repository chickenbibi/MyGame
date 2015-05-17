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
	self.move_handler = {}
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

function DataProcess:CastSkill(role_id,skill_id)
	printf("CastSkill:%d -- %d",role_id,skill_id)
	if not self:JudgeifSkillCd(role_id,skill_id) then
		return
	end
	if not self.role_data_table then
		return
	end
	local skill_range = self:GetSkillRange(skill_id)
	if not skill_range then
		return
	end
	local target = {}
	for i = 1 , #self.role_data_table do
		if self:GetRoleInRange(role_id,self.role_data_table[i]:GetRoleId(),skill_range) then
			printf("self.role_data_table[%d] is target !!!",i)
			table.insert(target,self.role_data_table[i])
		end
	end
	self:CauseDamage(role_id,skill_id,target)
	self:CauseEffect(role_id,skill_id,target)
	self:CalSkillCd(role_id,skill_id)
end

function DataProcess:CalSkillCd(role_id,skill_id)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	local cd = self:GetSkillCd(skill_id)
	role_info:CalSkillCd(skill_id,cd)
end

function DataProcess:JudgeifSkillCd(role_id,skill_id)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	return role_info:JudgeifSkillCd(skill_id)
end

function DataProcess:GetRoleInRange(role_id,target_id,skill_range,no_direction)
	local role_info = self:GetRoleInfo(role_id)
	local target_info = self:GetRoleInfo(target_id)
	if not role_info or not target_info or not skill_range or not self.role_data_table then
		return
	end
	if target_info:GetRoleType() == role_info:GetRoleType() then
		return
	end
	if math.abs(target_info:GetPosition().x - role_info:GetPosition().x) <= skill_range.x and
	   math.abs(target_info:GetPosition().y - role_info:GetPosition().y) <= skill_range.y
	then
		if not no_direction then
		   	if target_info:GetPosition().x * role_info:GetDirection() >= role_info:GetPosition().x * role_info:GetDirection() then
				return true
			end
		else
			return true
		end
	end
	return false
end

function DataProcess:CauseDamage(role_id,skill_id,target)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info or not target then
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

function DataProcess:CauseEffect(role_id,skill_id,target)

end

function DataProcess:GetSkillRange(skill_id)
	if not skill_id or not config_skill[skill_id] then
		return
	end
	return config_skill[skill_id].range
end

function DataProcess:GetSkillCd(skill_id)
	if not skill_id or not config_skill[skill_id] then
		return
	end
	return config_skill[skill_id].cd
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

function DataProcess:MoveRole(role_id,target_pos)
	-- printf("Moving to x: %d",target_pos.x)
	-- printf("Moving to y: %d",target_pos.y)
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.move_handler[role_id] then
		scheduler.unscheduleGlobal(self.move_handler[role_id])
		self.move_handler[role_id] = nil
	end
	self:SetRolePosition(role_id,target_pos)
	self.move_handler[role_id] = scheduler.scheduleGlobal(function()
															  	  self:SetRolePosition(role_id,target_pos)
															  end,
															  CONFIG_MOVE_RATE)
end

function DataProcess:StopRole(role_id)
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if self.move_handler[role_id] then
		scheduler.unscheduleGlobal(self.move_handler[role_id])
		self.move_handler[role_id] = nil
	end
end

function DataProcess:SetRolePosition(role_id,target_pos)
	if not role_id or not target_pos then
	    return
	end
	local role_info = self:GetRoleInfo(role_id)
	local role_pos = role_info:GetPosition()
	local moveby_x = target_pos.x - role_pos.x
	local moveby_y = target_pos.y - role_pos.y
	local distance = math.sqrt(math.pow((moveby_x), 2) + math.pow((moveby_y), 2))
	if distance >= CONFIG_MOVE_PIX then
	    local pos = {}
	    pos.x = role_pos.x + CONFIG_MOVE_PIX * moveby_x / distance
	    pos.y = role_pos.y + CONFIG_MOVE_PIX * moveby_y / distance
		if role_info:GetRoleType() == PLAYER_ROLE or 
			(role_info:GetRoleType() == ENEMY_ROLE and not role_info:GetFocus()) then
			self:TurnRoleAround(role_id,pos.x - role_info:GetPosition().x)
		end
		self:DirectToPlayer()
	    role_info:SetPosition(pos)
		SceneManager.Instance:SetRolePosition(role_id,pos)
	else
	    local pos = {}
	    pos.x = role_pos.x + moveby_x
	    pos.y = role_pos.y + moveby_y
		if role_info:GetRoleType() == PLAYER_ROLE or 
			(role_info:GetRoleType() == ENEMY_ROLE and not role_info:GetFocus()) then
			self:TurnRoleAround(role_id,pos.x - role_info:GetPosition().x)
		end
		self:DirectToPlayer()
	    role_info:SetPosition(pos)
		SceneManager.Instance:SetRolePosition(role_id,pos)

		if self.move_handler[role_id] then
		    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
			scheduler.unscheduleGlobal(self.move_handler[role_id])
		end
	end
end

function DataProcess:SetDirection(role_id,direction)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	role_info:SetDirection(direction)
end

function DataProcess:DirectToPlayer()
	local player_info = self:GetRoleInfo(SceneManager.Instance:GetPlayerRoleId())
	if not player_info then
		return
	end
	if not self.role_data_table then
		return
	end
	for i = 1, #self.role_data_table do
		if self.role_data_table[i]:GetRoleType() == ENEMY_ROLE and self.role_data_table[i]:GetFocus() then
			self:TurnRoleAround(self.role_data_table[i]:GetRoleId(), 
							  player_info:GetPosition().x - self.role_data_table[i]:GetPosition().x)
		end
	end
end

function DataProcess:SetFocus(role_id,state)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	role_info:SetFocus(state)
end

function DataProcess:TurnRoleAround(role_id,direction)
	local role_info = self:GetRoleInfo(role_id)
	if not role_info then
		return
	end
	if direction then
		role_info:SetDirection(direction)
	else
		role_info:SetDirection(-role_info:GetDirection())
	end
	
end