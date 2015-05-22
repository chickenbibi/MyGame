QuickSkill = QuickSkill or BaseClass()

function QuickSkill:__init()
	if QuickSkill.Instance ~= nil then
	    error("QuickSkill must be singleton!")
	end
	QuickSkill.Instance = self
	self.skill = {}

	self:InitSprite()
	self:InitEvents()
end

function QuickSkill:InitSprite()
	self.skill["base_skill"] = display.newSprite("res/units/quick_skill/base_skill.png", display.right - 120, display.bottom + 122)
	self.skill["base_skill"]:setAnchorPoint(cc.p(0.5, 0.5))
	self.skill["base_skill"]:retain()
end

function QuickSkill:InitEvents()
	self.handle["base_skill"] = function()
		print("I'm attacking !!!")
	end

	self:RegisterEvents()
end

function QuickSkill:RegisterEvents()
	for k,v in pairs(self.skill) do
		v
		:onButtonPressed(function(event)
			event.target:setScale(0.9)
		end)
		:onButtonRelease(function(event)
			event.target:setScale(1.0)
		end)
		:onButtonClicked(function(event)
			self.handle[k]
		end)
	end
end

function QuickSkill:AddToLayer(layer)
	for k,v in pairs(self.skill) do
		layer:addChild(v)
	end
end

function QuickSkill:RemoveFromLayer()
	for k,v in pairs(self.skill) do
		if v:getParent() then
			v:removeFromParent()
		end
	end
end