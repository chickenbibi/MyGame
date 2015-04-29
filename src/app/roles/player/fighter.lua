Fighter = Fighter or BaseClass(BaseRole)

-- fighter类独有事件
local events = {
}

-- fighter类独有事件回调
local callbacks = {
}

function Fighter:__init(attr,events,callbacks)
end

function Fighter:onAttack()
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
        display.setAnimationCache("fighter-" .. animationNames[i], animation)
    end
end