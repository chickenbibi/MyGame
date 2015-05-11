--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		enemy_ai
Description: 	敌人的AI行为控制
Author: 		Luoheng
Email:			287429173@qq.com
]]
EnemyAI = EnemyAI or BaseClass(BaseRole)

function EnemyAI:__init()
	-- if not self.handle then
 --    	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
 --    	self.handle = scheduler.scheduleGlobal(function() self:SignRange() end, 1)
 --    end
	 -- self:MoveToPlayer()
end

function EnemyAI:xx()
	
end

function EnemyAI:SignRange()
	local ret = DataProcess.Instance:GetRoleInRange(
													self:GetRoleId(),
													SceneManager.Instance:GetPlayerRoleId(),
													self.__default_arg.sign_range,
													true
													)
	if ret then
		print("Got Player In Range !!!")
		if self.handle then
	    	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	    	scheduler.unscheduleGlobal(self.handle)
	    	self.handle = nil
	    end
	    self:StartAttack()
	end
	ret = false
end

function EnemyAI:StartAttack()
	self:RandomAttackPattern()
end

function EnemyAI:RandomAttackPattern()
	local pattern = math.random(1,10000)
	self:AttackByPattern(pattern)
end

function EnemyAI:AttackByPattern(pattern)
end

function EnemyAI:GetSkillConfig(skill_id)
	return config_skill[skill_id]
end

function EnemyAI:MoveToPlayer()
	local skill_config = self:GetSkillConfig(100)
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	local player_pos = player:GetPosition()
	local offsetX = math.random(-(player_pos.x - self:GetPosition().x) / 2,player_pos.x - self:GetPosition().x)
	local offsetY = math.random(-(player_pos.y - self:GetPosition().y) / 2,player_pos.y - self:GetPosition().y)
	local distance = math.sqrt(math.pow(offsetX,2),math.pow(offsetY,2))
	local pos = {
		x = self:GetPosition().x + offsetX,
		y = self:GetPosition().y + offsetY,
	}
	DataProcess.Instance:MoveRole(self:GetRoleId(),pos)
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	scheduler.performWithDelayGlobal(function()
									 	self:MoveToPlayer()	
									 end,
									 distance/CONFIG_MOVE_PIX)
end