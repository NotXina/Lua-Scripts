-- ============================================================================
-- AUTO SD NO TARGET
-- Lança Sudden Death (SD) no alvo atual respeitando a distância da tela
-- ============================================================================

local sdId = 3155 -- ID da runa de SD (ou 2268)

macro(100, "Auto SD Target", function()
  local target = g_game.getAttackingCreature()
  if target then
    local tPos = target:getPosition()
    if tPos.z == posz() and getDistanceBetween(pos(), tPos) <= 7 then
      useWith(sdId, target)
      delay(200)
    end
  end
end)
