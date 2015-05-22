--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		game_start
Description: 	开始场景
Author: 		Luoheng
Email:			287429173@qq.com
]]

GameStartScene = GameStartScene or BaseClass(BaseScene)

function GameStartScene:__init()
	if GameStartScene.Instance ~= nil then
	    error("GameStartScene must be singleton!")
	end
	GameStartScene.Instance = self
	cc.FileUtils:getInstance():addSearchPath("res/scenes/game_start/")
	cc.uiloader:load("game_start.json"):addTo(self:GetScene())
	self:LoadJsonCallBack()
	self:InitEvents()
	self:SetNextScene(BattleScene.Instance)
end

function GameStartScene:LoadSceneConfig()
	self.scene_config = self:GetSceneConfig("GameStartScene")
end

function GameStartScene:LoadJsonCallBack()
	self.btn_start = cc.uiloader:seekNodeByName(self:GetScene(), "btn_start")
end

function GameStartScene:InitEvents()
	self.btn_start
		:onButtonPressed(function(event)
			event.target:setScale(0.55)
		end)
		:onButtonRelease(function(event)
			event.target:setScale(0.6)
		end)
		:onButtonClicked(function(event)
			self:EnterNextScene()
		end)
end