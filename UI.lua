local env = getgenv()

function env.import(id)
  return game:GetObjects(id)[1]
end

return import("rbxassetid://24988523784698")
