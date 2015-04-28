require("config")
require("cocos.init")
require("framework.init")
require("app.scenes.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	SceneManager.New()
    display.replaceScene(GameStartScene.Instance)
end

function MyApp:exit()
	SceneManager.Instance:ResetData()
	MyApp.super.exit()
end

return MyApp
