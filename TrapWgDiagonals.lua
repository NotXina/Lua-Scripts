-- ============================================================================
-- TRAP WG DIAGONALS
-- Joga Wild Growth automaticamente nas 4 diagonais do seu alvo para trapar
-- ============================================================================

local wgId = 3156 -- ID da Wild Growth

macro(100, "Trap WG Diagonals", function()
  local target = g_game.getAttackingCreature()
  if not target then return end
  
  local tPos = target:getPosition()
  if tPos.z ~= posz() or getDistanceBetween(pos(), tPos) > 6 then return end

  local offsets = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}
  for _, off in ipairs(offsets) do
    local checkPos = {x = tPos.x + off[1], y = tPos.y + off[2], z = tPos.z}
    local tile = g_map.getTile(checkPos)
    if tile and tile:isWalkable() then
      useWith(wgId, tile:getTopUseThing() or tile:getGround())
      delay(150)
      return
    end
  end
end)
