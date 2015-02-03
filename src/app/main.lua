--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		main
Description: 	游戏入口；初始化场景管理器、数据处理器；
Author: 		Luoheng
Email:			287429173@qq.com
Version: 		beta-0.5
Date: 			4-30-2015
]]
require("config")
require("cocos.init")
require("framework.init")
require("framework.cc.mvc.BaseClass")
-- 其他组件类
require("app.units.init")
-- 数据处理类
require("app.data_process.init")
-- 事件定义
require("app.events.init")
-- 角色类
require("app.roles.init")
-- 场景类
require("app.scenes.init")


local main = class("main", cc.mvc.AppBase)

function main:ctor()
    main.super.ctor(self)
end

function main:run()
	display.addSpriteFrames("res/roles/fighter.plist", "res/roles/fighter.png");
	display.addSpriteFrames("res/roles/soldier.plist", "res/roles/soldier.png");


	DataProcess.New()
	SceneManager.New()

    display.replaceScene(GameStartScene.Instance)
end

function main:ResetData()
	DataProcess.Instance:ResetData()
	SceneManager.Instance:ResetData()
end

function main:exit()
	display.removeSpriteFramesWithFile("res/roles/fighter.plist", "res/roles/fighter.png");
	
	DataProcess.DeleteMe()
	
	SceneManager.Instance:ResetData()
	SceneManager.DeleteMe()

	main.super.exit()
end

return main
