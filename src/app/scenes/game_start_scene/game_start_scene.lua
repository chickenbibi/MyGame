--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		game_start_scene
Description: 	游戏开始场景
Author: 		Luoheng
Email:			287429173@qq.com
]]
GameStartScene = GameStartScene or class("GameStartScene", function()
    return display.newScene("GameStartScene")
end)

function GameStartScene:ctor()
	if GameStartScene.Instance ~= nil then
	    error("GameStartScene must be singleton!")
	end
	GameStartScene.Instance = self
	cc.FileUtils:getInstance():addSearchPath("res/scenes/game_start/")
	cc.uiloader:load("game_start.json"):addTo(self)

	self:LoadJsonCallBack()
end

function GameStartScene:LoadJsonCallBack()
	self.btn_start = cc.uiloader:seekNodeByName(self, "btn_start")

	self:InitEvents()
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

function GameStartScene:EnterNextScene()
    SceneManager.Instance:EnterScene(BattleScene.Instance)
    SceneManager.Instance:DeleteSceneFromMgr(GameStartScene.Instance)
end
