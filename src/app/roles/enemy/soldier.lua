--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		soldier
Description: 	士兵行为类
Author: 		Luoheng
Email:			287429173@qq.com
]]
Soldier = Soldier or BaseClass(BaseRole)

Soldier.__default_arg = {
	sprite_name = "#soldier-walk-1.png",
	events = {},
	callbacks = {},
}


function Soldier:__init(attr)
	self:AddAnimation()
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