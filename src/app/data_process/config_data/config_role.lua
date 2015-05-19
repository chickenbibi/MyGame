--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		config_role
Description: 	角色数据定义
Author: 		Luoheng
Email:			287429173@qq.com
]]


--[[
id 				角色种类
base_hp 		基础血量
grow_hp			成长血量
base_damage		基础伤害
graw_damage 	成长伤害
float_damage	伤害浮动值
speed 			移动速度
role_type 		角色类型
]]

PLAYER_ROLE = 1
ENEMY_ROLE = 2

config_role = {
	[1] = {
		name = "基础角色",
		base_hp = 500,
		grow_hp = 80,
		base_damage = 80,
		graw_damage = 10,
		float_damage = 5,
		speed = 1,
	},

	[100] = {
		name = "格斗家",
		base_hp = 100,
		grow_hp = 100,
		base_damage = 90,
		graw_damage = 10,
		float_damage = 10,
		speed = 1,
		role_type = PLAYER_ROLE,
	},

	[1000] = {
		name = "士兵",
		base_hp = 600,
		grow_hp = 100,
		base_damage = 80,
		graw_damage = 10,
		float_damage = 10,
		speed = 1,
		role_type = ENEMY_ROLE,
	}
}