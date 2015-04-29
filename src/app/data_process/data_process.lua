DataProcess = DataProcess or BaseClass()

function DataProcess:__init()
	if DataProcess.Instance ~= nil then
	    error("BattleScene must be singleton!")
	end
	DataProcess.Instance = self
end