-- ============================================================================
-- PROTEÇÃO DE SQM COM FLORES (F7)
-- Planta flores nos 8 SQMs ao redor da posição marcada para impedir traps
-- ============================================================================

local flowerIds = {2981, 2983, 2984, 2985}
local flowerDirs = {
  {x=0, y=-1}, {x=1, y=0}, {x=0, y=1}, {x=-1, y=0},
  {x=1, y=-1}, {x=1, y=1}, {x=-1, y=1}, {x=-1, y=-1}
}

local protectPos = nil
local protectActive = false

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

local function plantAround(centerPos)
  if not centerPos then return end
  for _, off in ipairs(flowerDirs) do
    local p = {x = centerPos.x + off.x, y = centerPos.y + off.y, z = centerPos.z}
    local tile = g_map.getTile(p)
    if tile and not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, p, 1)
        delay(100)
        return
      end
    end
  end
end

-- Hotkey F7: Marca/Desmarca SQM para proteger
singlehotkey("F7", "Proteger Sqm", function()
  local tile = getTileUnderCursor()
  if not tile then return end
  local p = tile:getPosition()

  if protectPos and p.x == protectPos.x and p.y == protectPos.y and p.z == protectPos.z then
    tile:setText("")
    protectPos = nil
    protectActive = false
    return
  end

  if protectPos then
    local oldTile = g_map.getTile(protectPos)
    if oldTile then oldTile:setText("") end
  end

  tile:setText("Proteger", "green")
  protectPos = p
  protectActive = true
  plantAround(protectPos)
end)

onKeyDown(function(keys)
  if keys:upper() == "ESC" and protectPos then
    local tile = g_map.getTile(protectPos)
    if tile then tile:setText("") end
    protectPos = nil
    protectActive = false
  end
end)

onRemoveThing(function(tile, thing)
  if not protectActive or not protectPos then return end
  local p = tile:getPosition()
  if p.z ~= protectPos.z then return end

  local dx, dy = math.abs(p.x - protectPos.x), math.abs(p.y - protectPos.y)
  if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0) then
    if not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, p, 1)
      end
    end
  end
end)
