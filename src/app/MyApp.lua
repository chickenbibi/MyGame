require("config")
require("cocos.init")
require("framework.init")
-- 数据处理类
require("app.data_process.init")
-- 事件定义
require("app.events.init")
-- 角色类
require("app.roles.init")
-- 场景类
require("app.scenes.init")


local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	display.addSpriteFrames("res/roles/role.plist", "res/roles/role.pvr.ccz");
	DataProcess.New()
	SceneManager.New()

    display.replaceScene(GameStartScene.Instance)
end

function MyApp:ResetData()
	DataProcess.Instance:ResetData()
	SceneManager.Instance:ResetData()
end

function MyApp:exit()
	DataProcess.DeleteMe()
	
	SceneManager.Instance:ResetData()
	SceneManager.DeleteMe()

	MyApp.super.exit()
end

return MyApp
