--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		soldier
Description: 	士兵行为类
Author: 		Luoheng
Email:			287429173@qq.com
]]
Soldier = Soldier or BaseClass(EnemyAI)

Soldier.__default_arg = {
	sprite_name = "#soldier-walk-1.png",

	pos_offset = {
		x = 0,
		y = -8,
	},

	patrol_range = {
		x = 200,
		y = 100,
	},

	-- 视野范围
	sign_range = {
		x = 300,
		y = 100,
	},

	-- 攻击模式
	attack_pattrn = {
		[1] = { name = "basic_attack", rate = 10000, skill_id = 100,},
	},

	-- 移动模式
	move_pattern = {
		[1] = { name = "move_to_front", rate = 5000},
		[2] = { name = "move_to_back", rate = 10000},
	},
}

function Soldier:__init(attr)
	self:AddAnimation()
	self:AddMovePattern()
	self:SetupStateMachine()
end

function Soldier:AddAnimation()
	-- 创建动作帧
    local animationNames = {"walk","attack","hit","dead"}
    local animationFrameNum = {3, 3, 3, 3}
 
    for i = 1, #animationNames do
        local frames = display.newFrames("soldier-" .. animationNames[i] .. "-%d.png", 1, animationFrameNum[i])
        local animation = display.newAnimation(frames, 0.1)
        display.setAnimationCache("soldier-" .. animationNames[i], animation)
    end
end

function Soldier:AddMovePattern()
	self.move_pattern = {
		["move_to_front"] = handler(self,self.MoveToFront),
		["move_to_back"] = handler(self,self.MoveToBack),
	}
end

function Soldier:PlayHitAnimation()
	transition.playAnimationOnce(self.sprite, display.getAnimationCache("soldier-hit"))
end

function Soldier:ToDead()
	-- 死亡动作
	transition.playAnimationOnce(self.sprite, display.getAnimationCache("soldier-dead"))
	transition.fadeTo(self.sprite, 
						{opacity = 0, 
						 time = 2, 
						 onComplete = function() 
						 				self.sprite:removeFromParent()
						 				self:DeleteMe()
						 				print("I'm Realy Dead !!!")
						 			  end
						}
					 )
end

function Soldier:AttackByPattern(pattern)
	-- if not pattern then
	--     return
	-- end
	-- if pattern < self.__default_arg.attack_pattrn.basic_attack then
	--     self:BasicAttack()
	-- end
end

function Soldier:BasicAttack()
	local player = SceneManager.Instance:GetRoleById(SceneManager.Instance:GetPlayerRoleId())
	local skill_config = self:GetSkillConfig(100)
	local offsetX = math.random(-skill_config.range.x,skill_config.range.x)
	local offsetY = math.random(-skill_config.range.y,skill_config.range.y)
	local pos = {
		x = player:GetPosition().x + offsetX,
		y = player:GetPosition().x + offsetY,
	}
	DataProcess.Instance:MoveRole(self:GetRoleId(),pos)
end