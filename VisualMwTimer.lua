-- ============================================================================
-- TIMER VISUAL DE MAGIC WALL NO CHÃO
-- Escreve a contagem regressiva em segundos em cima de todas as walls da tela
-- ============================================================================

local mwDuration = 20000 -- Duração da MW em ms (20 segundos)
local wallTimers = {}

local wallIds = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [10188] = true, [10189] = true
}

macro(50, "Visual MW Timer", function()
  local pPos = pos()
  local t = now or g_clock.millis()

  for _, tile in ipairs(g_map.getTiles(pPos.z) or {}) do
    local posKey = tile:getPosition().x .. "," .. tile:getPosition().y
    local hasMw = false
    
    for _, it in ipairs(tile:getItems() or {}) do
      if wallIds[it:getId()] then
        hasMw = true
        break
      end
    end

    if hasMw then
      if not wallTimers[posKey] then
        wallTimers[posKey] = t + mwDuration
      end
      local remaining = math.max(0, (wallTimers[posKey] - t) / 1000)
      tile:setText(string.format("%.1fs", remaining))
    else
      if wallTimers[posKey] then
        wallTimers[posKey] = nil
        tile:setText("")
      end
    end
  end
end)
