-- ============================================================================
-- INIMIGO TARGET HUD
-- Mostra o Nick, Vida % e Distância do seu alvo no topo da tela
-- ============================================================================

local targetLabel = UI.Label()
targetLabel:setPosition({x = 450, y = 30})
targetLabel:setFont("verdana-11px-rounded")
targetLabel:setColor("red")

macro(50, "Target HUD", function()
  local target = g_game.getAttackingCreature()
  if target and target:isPlayer() then
    local hp = target:getHealthPercent()
    local dist = getDistanceBetween(pos(), target:getPosition())
    targetLabel:setText(string.format("ALVO: %s | HP: %d%% | DIST: %d", target:getName(), hp, dist))
    targetLabel:show()
  else
    targetLabel:hide()
  end
end)
