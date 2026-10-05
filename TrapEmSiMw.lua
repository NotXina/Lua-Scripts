-- ============================================================================
-- TRAPA EM SI MW (8 SQMs AO REDOR)
-- Preenche os 8 SQMs ao redor do próprio char com Magic Wall
-- ============================================================================

local MW_RUNE_ID = 3180
local MW_ITEM_IDS = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [10188] = true, [10189] = true
}

local wallOffsets = {
  {-1, -1}, { 0, -1}, { 1, -1},
  {-1,  0},           { 1,  0},
  {-1,  1}, { 0,  1}, { 1,  1}
}

local function hasWall(tile)
  if not tile then return true end
  for _, item in ipairs(tile:getItems() or {}) do
    if MW_ITEM_IDS[item:getId()] then return true end
  end
  return false
end

local function throwMw(offsetX, offsetY)
  local player = g_game.getLocalPlayer()
  if not player then return false end

  local pPos = player:getPosition()
  local targetPos = {x = pPos.x + offsetX, y = pPos.y + offsetY, z = pPos.z}
  local tile = g_map.getTile(targetPos)

  if tile and not hasWall(tile) and tile:isWalkable(false) then
    local ground = tile:getTopUseThing() or tile:getGround()
    if ground then
      useWith(MW_RUNE_ID, ground)
      return true
    end
  end
  return false
end

macro(50, "Trapa em si MW", "NumPad5", function()
  for _, off in ipairs(wallOffsets) do
    if throwMw(off[1], off[2]) then
      delay(200)
      return
    end
  end
end)
