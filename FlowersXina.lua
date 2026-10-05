-- ============================================================================
-- FLOWERS AO REDOR DO CHAR
-- Planta flores nos 8 SQMs ao redor do próprio jogador automaticamente
-- ============================================================================

local flowerIds = {2981, 2983, 2984, 2985}
local flowerDirs = {
  {x=0, y=-1}, {x=1, y=0}, {x=0, y=1}, {x=-1, y=0},
  {x=1, y=-1}, {x=1, y=1}, {x=-1, y=1}, {x=-1, y=-1}
}

local function hasFlower(tile)
  if not tile then return false end
  local item = tile:getTopThing()
  return item and table.find(flowerIds, item:getId())
end

local function getFlowerItem()
  for _, id in ipairs(flowerIds) do
    local item = findItem(id)
    if item then return item end
  end
  return nil
end

macro(250, "Flowers Xina", function()
  local pPos = pos()
  for _, off in ipairs(flowerDirs) do
    local targetPos = {x = pPos.x + off.x, y = pPos.y + off.y, z = pPos.z}
    local tile = g_map.getTile(targetPos)
    if tile and not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, targetPos, 1)
        delay(150)
        return
      end
    end
  end
end)
