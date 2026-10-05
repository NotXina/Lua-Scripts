-- ============================================================================
-- AUTO DESTROY FIELD E FLORES
-- Remove Fire, Poison ou Energy embaixo do char e flores nos 8 tiles ao redor
-- ============================================================================

local destroyRuneId = 3148    -- ID da runa de Destroy Field
local disintegrateRuneId = 3197 -- ID da runa de Disintegrate

local dangerousFields = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire
  [2123] = true, [2124] = true, [2125] = true, -- Poison
  [2126] = true, [2127] = true                 -- Energy
}

local flowerIds = {
  [2981] = true, [2983] = true, [2984] = true, [2985] = true
}

local around = {
  {-1, -1}, {0, -1}, {1, -1},
  {-1,  0},          {1,  0},
  {-1,  1}, {0,  1}, {1,  1}
}

macro(150, "Auto Destroy Field", function()
  local p = g_game.getLocalPlayer()
  if not p then return end

  local pPos = p:getPosition()
  local tile = g_map.getTile(pPos)
  if not tile then return end

  -- Destroy Field embaixo do personagem tem prioridade.
  for _, item in ipairs(tile:getItems() or {}) do
    if dangerousFields[item:getId()] then
      useWith(destroyRuneId, item)
      delay(300)
      return
    end
  end

  -- Remove uma flor por vez dos 8 tiles ao redor do personagem.
  for _, offset in ipairs(around) do
    local flowerTile = g_map.getTile({
      x = pPos.x + offset[1],
      y = pPos.y + offset[2],
      z = pPos.z
    })

    if flowerTile then
      for _, item in ipairs(flowerTile:getItems() or {}) do
        if flowerIds[item:getId()] then
          useWith(disintegrateRuneId, item)
          delay(300)
          return
        end
      end
    end
  end
end)
