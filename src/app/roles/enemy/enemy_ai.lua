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
	end
end