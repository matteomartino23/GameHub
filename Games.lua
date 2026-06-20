local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/matteomartino23/GameHub/refs/heads/main/UI.lua"))()
local Games = {}

function Games:AddGame(tab, name id)
  tab:CreateGameTeleport(name, id)
end

return Games
