Fighter = Fighter or BaseClass(BaseRole)

Fighter.__default_arg = {
	sprite_name = "#fighter_walk-1.png",
	events = {},
	callbacks = {},
}

function Fighter:__init(attr)
	self.attack_pattrn = 1
	self:addAnimation()
end

function Fighter:onAttack()
	-- 当前攻击模式，1、2为轻击，3为重击
	self.attack_pattrn = (self.attack_pattrn + 1) % 3 + 1
	-- if
end

function Fighter:ChangeHp()
	-- HP改变事件，需要的时候开启
	-- self:dispatchEvent({name = SCENE_EVENT.HP_CHANGED_EVENT})
end

function Fighter:addAnimation()
	cc.FileUtils:getInstance():addSearchPath("res/roles/")
	-- 创建动作帧
    local animationNames = {"walk","attack1","attack2","hit","dead"}
    local animationFrameNum = {4, 4, 4, 2, 4}
 
    for i = 1, #animationNames do
        local frames = display.newFrames("fighter_" .. animationNames[i] .. "-%d.png", 1, animationFrameNum[i])
        local animation = display.newAnimation(frames, 0.2)
        display.setAnimationCache("fighter_" .. animationNames[i], animation)
    end
end

function Fighter:onTouch()
	local attack_pattrn = 1
	if self.attack_pattrn == 3 then
	    attack_pattrn = 2
	end
	transition.playAnimationForever(self.sprite, display.getAnimationCache("fighter_attack"..attack_pattrn))
end