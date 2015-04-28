GameStartScene = GameStartScene or class("GameStartScene", function()
    return display.newScene("GameStartScene")
end)

function GameStartScene:ctor()
	if GameStartScene.Instance ~= nil then
	    error("GameStartScene must be singleton!")
	end
	GameStartScene.Instance = self
	cc.FileUtils:getInstance():addSearchPath("res/game_start/")
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
    display.replaceScene(BattleScene.Instance)
    SceneManager.Instance:DeleteSceneFromMgr(GameStartScene.Instance)
end
