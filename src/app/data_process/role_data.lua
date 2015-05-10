--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		role_data
Description: 	所有角色数据类
Author: 		Luoheng
Email:			287429173@qq.com
]]
RoleData = RoleData or BaseClass()

function RoleData:__init(role_id,pos,index)
	self:ResetData(pos,index)
	self:LoadConfigData(role_id)
end

function RoleData:ResetData(pos,index)
	self.attr = {}
	self.attr.hp = 0
	self.attr.level = 1
	self.attr.pos = pos
	self.attr.direction = 1
	self.skill_cd_handler = {}
	self.attr.skill_cd = {}
	setmetatable(self.attr.skill_cd, 
				 {__index = function(t,k) return true end}
				 )
	-- 数据索引，角色数据唯一标识
	self.attr.role_id = index
end

function RoleData:LoadConfigData(role_id)
	if not role_id or not config_role[role_id] then
		error("Don't Have This Config Of Role !!!")
		return
	end
	for key, value in pairs(config_role[role_id]) do
		self.attr[key] = value
	end
	self.attr.hp = self.attr.base_hp + self.attr.grow_hp * self.attr.level
end

function RoleData:GetRoleType()
	return self.attr.role_type
end

function RoleData:GetRoleId()
	return self.attr.role_id
end

function RoleData:GetDirection()
	return self.attr.direction
end

function RoleData:GetPosition()
	return self.attr.pos
end

function RoleData:SetPosition(pos)
	if not pos then
	    return
	end
	self.attr.pos = pos
end

function RoleData:JudgeifSkillCd(skill_id)
	return self.attr.skill_cd[skill_id]
end

function RoleData:CalSkillCd(skill_id,cd)
	if not skill_id then
		error("[RoleData:CalSkillCd]:Skill_id Wrong !!!")
	end
	if cd == 0 then
		return
	end
	self.attr.skill_cd[skill_id] = false
	if not self.skill_cd_handler[skill_id] then
		local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    	self.skill_cd_handler[skill_id] = scheduler.scheduleGlobal( function() 
	    															        self.attr.skill_cd[skill_id] = true 
	    															        if self.skill_cd_handler[skill_id] then
	    															        	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
		    															        scheduler.unscheduleGlobal(self.skill_cd_handler[skill_id])
		    															        self.skill_cd_handler[skill_id] = nil
		    															    end
	    															     end, 
	    															     cd)
    end
end

function RoleData:SetDirection(direction)
	if direction > 0 then
		self.attr.direction = 1
	elseif direction < 0 then
		self.attr.direction = -1
	end
end

function RoleData:GetAttr()
	return self.attr
end

function RoleData:GetHp()
	return self.attr.hp
end

function RoleData:GetDamage()
	local role_damage = self.attr.base_damage + 
						self.attr.graw_damage * self.attr.level +
						math.random(-self.attr.float_damage,self.attr.float_damage)
	return role_damage
end

function RoleData:DecreaseHp(damage)
	if not damage then
		return
	end
	if self.attr.hp <= damage then
		self.attr.hp = 0
		return self.attr.hp
	end
	self.attr.hp = self.attr.hp - damage
	return self.attr.hp
end