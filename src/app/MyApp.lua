--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		fighter
Description: 	战士行为类
Author: 		Luoheng
Email:			287429173@qq.com
Version: 		beta-0.5
Date: 			4-30-2015
]]
require("config")
require("cocos.init")
require("framework.init")
require("framework.cc.mvc.BaseClass")
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
	display.addSpriteFrames("res/roles/fighter.plist", "res/roles/fighter.png");


	DataProcess.New()
	SceneManager.New()

    display.replaceScene(GameStartScene.Instance)
end

function MyApp:ResetData()
	DataProcess.Instance:ResetData()
	SceneManager.Instance:ResetData()
end

function MyApp:exit()
	display.removeSpriteFramesWithFile("res/roles/fighter.plist", "res/roles/fighter.png");
	
	DataProcess.DeleteMe()
	
	SceneManager.Instance:ResetData()
	SceneManager.DeleteMe()

	MyApp.super.exit()
end

return MyApp
