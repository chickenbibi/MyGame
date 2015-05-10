--[[
Copyright:		2015, Luoheng. All rights reserved.
File name: 		config_skill
Description: 	技能数据定义
Author: 		Luoheng
Email:			287429173@qq.com
]]

--[[
name 	技能名称
damage 	伤害
range 	攻击范围(X轴)
cd 		冷却时间
]]


config_skill = {
	[100] = {
		name = "普通攻击",
		damage = 0,
		range = {
			x = 150,
			y = 10,
		},
		cd = 0,
	}
}