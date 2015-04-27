require("config")
require("cocos.init")
require("framework.init")
require("app.scenes.game_start_scene.game_start_scene")
require("app.scenes.battle_scene.battle_scene")
GameStartScene.new()
BattleScene.new()

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    display.replaceScene(GameStartScene.Instance)
end

return MyApp
