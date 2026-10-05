-- ============================================================================
-- TRAMONTINA / MACHETE NO WG
-- Corta automaticamente qualquer Wild Growth que estiver ao seu redor
-- ============================================================================

local config = {
  macheteId = 3308,
  hotkey = "F1",
  wgWallId = 2130
}

local function getNearTiles(centerPos)
  if not centerPos then return {} end
  local tiles = {}
  local offsets = {
    {-1, 1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {-1, -1}, {0, -1}, {1, -1}
  }
  for _, off in ipairs(offsets) do
    local tile = g_map.getTile({
      x = centerPos.x - off[1],
      y = centerPos.y - off[2],
      z = centerPos.z
    })
    if tile then table.insert(tiles, tile) end
  end
  return tiles
end

addIcon("TramontinaIcon", {item = {id = config.macheteId, count = 1}, text = "Machete", hotkey = config.hotkey}, macro(200, function()
  for _, tile in ipairs(getNearTiles(pos())) do
    local topThing = tile:getTopThing()
    if topThing and topThing:getId() == config.wgWallId then
      useWith(config.macheteId, topThing)
      return
    end
  end
end))
