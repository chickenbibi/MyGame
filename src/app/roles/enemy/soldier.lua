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
		x = 43,
		regular_y = -8,
		regular_x = 0,
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
		[1] = { action = "basic_attack", rate = 10000, skill_id = 100,},
	},

	-- 移动模式
	move_pattern = {
		[1] = { action = "move_to_front", rate = 5000},
		[2] = { action = "move_to_back", rate = 10000},
	},

	-- 总的行为模式
	pattern = {
		[1] = { name = "attack", rate = 8000, action = "attack_pattrn", range = {}},
		[2] = { name = "move", rate = 10000, action = "move_pattern", range = {x = 200, y = 100}},
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
    local animationFrameTime = {0.2,0.1,0.1,0.1,}
 
    for i = 1, #animationNames do
        local frames = display.newFrames("soldier-" .. animationNames[i] .. "-%d.png", 1, animationFrameNum[i])
        local animation = display.newAnimation(frames, animationFrameTime[i])
        display.setAnimationCache("soldier-" .. animationNames[i], animation)
    end
end

function Soldier:AddMovePattern()
	self.pattern = {
		["attack_pattrn"] = handler(self, self.RandomAttackPattern),
		["move_pattern"] = handler(self, self.RandomMovePattern),
	}
	self.move_pattern = {
		["move_to_front"] = handler(self,self.MoveToFront),
		["move_to_back"] = handler(self,self.MoveToAround),
	}
end

