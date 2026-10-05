-- ============================================================================
-- AUTO DESTROY FIELD NO PÉ
-- Remove automaticamente Fire, Poison ou Energy jogados embaixo do char
-- ============================================================================

local destroyRuneId = 3148 -- ID da runa de Destroy Field

local dangerousFields = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire
  [2123] = true, [2124] = true, [2125] = true, -- Poison
  [2126] = true, [2127] = true                 -- Energy
}

macro(150, "Auto Destroy Field", function()
  local p = g_game.getLocalPlayer()
  if not p then return end
  local tile = g_map.getTile(p:getPosition())
  if not tile then return end

  for _, item in ipairs(tile:getItems() or {}) do
    if dangerousFields[item:getId()] then
      useWith(destroyRuneId, item)
      delay(300)
      return
    end
  end
end)
