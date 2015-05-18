--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		fighter
Description: 	战士行为类
Author: 		Luoheng
Email:			287429173@qq.com
]]
Fighter = Fighter or BaseClass(BaseRole)

Fighter.__default_arg = {
	sprite_name = "#fighter-walk-1.png",
	pos_offset = {
		x = 40,
		regular_y = 0,
		regular_x = 0,
	},
}

function Fighter:__init(attr)
	self.attack_pattrn = 3
	self:AddAnimation()
	self:SetupStateMachine()
end

function Fighter:ChangeHp()
	-- HP改变事件，需要的时候开启
	-- self:dispatchEvent({name = SCENE_EVENT.HP_CHANGED_EVENT})
end

function Fighter:AddAnimation()
	-- 创建动作帧
    local animationNames = {"walk","attack1","attack2","hit","dead"}
    local animationFrameNum = {4, 4, 4, 3, 4}
    local animationFrameTime = {0.2,0.1,0.1,0.1,0.1,}
 
    for i = 1, #animationNames do
        local frames = display.newFrames("fighter-" .. animationNames[i] .. "-%d.png", 1, animationFrameNum[i])
        local animation = display.newAnimation(frames, animationFrameTime[i])
        display.setAnimationCache("fighter-" .. animationNames[i], animation)
    end
end

function Fighter:onTouch()
	if self.fsm:isState("attacking") then
		return
	end
	if not DataProcess.Instance:JudgeifSkillCd(self:GetRoleId(),100) then
		return
	end
	if self.fsm:canDoEvent("attack") then
		self.fsm:doEvent("attack")
	end
end

function Fighter:DoMoveEvent()
	if not self.fsm:isState("idle") then
		return
	end
	self.fsm:doEvent("walk")
end

-- function Fighter:onbeforeAttack()
-- 	-- 当前攻击模式，1、2为轻击，3为重击
-- 	self.attack_pattrn = (self.attack_pattrn + 1) % 3 + 1
-- 	local attack_pattrn = 2
-- 	if self.attack_pattrn == 3 then
-- 	    attack_pattrn = 1
-- 	end
-- 	transition.playAnimationOnce(self.sprite, 
-- 								 display.getAnimationCache("fighter-attack"..attack_pattrn),
-- 								 nil,
-- 								 function() self:AttackCallBack() end)
-- end

-- function Fighter:AttackCallBack()
-- 	DataProcess.Instance:CastSkill(self:GetRoleId(),100)
-- 	self:Stop()
-- end

function Fighter:onAttacking()
	local func = function()
		DataProcess.Instance:CastSkill(self:GetRoleId(),100)
		if not self.fsm:isState("idle") then
			self.fsm:doEvent("stop")
		end
	end

	-- 当前攻击模式，1、2为轻击，3为重击
	self.attack_pattrn = (self.attack_pattrn + 1) % 3 + 1
	local attack_pattrn = 2
	if self.attack_pattrn == 3 then
	    attack_pattrn = 1
	end
	self:PlayAnimationOnce("attack"..attack_pattrn,func)
end

function Fighter:Stop()
	if not self.fsm:isState("idle") then
		self.fsm:doEvent("stop")
	end
end

function BaseRole:ToDead()
	StickUnits.Instance:RemoveFromScene()
	if self.fsm:canDoEvent("stop") then
		self.fsm:doEvent("stop")
	end
	self.fsm:doEvent("killed")
end
