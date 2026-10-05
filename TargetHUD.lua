-- ============================================================================
-- INIMIGO TARGET HUD
-- Mostra o Nick, Vida % e Distância do seu alvo no topo da tela
-- ============================================================================

-- Destrói o label anterior para não duplicar ao recarregar o script
if targetHudLabel then
  targetHudLabel:destroy()
  targetHudLabel = nil
end

-- UI.Label() criava o texto dentro do painel do bot (que usa layout vertical),
-- onde setPosition() é ignorado - o HUD nunca aparecia na tela. O label precisa
-- ser criado no rootWidget, igual ao StatusExpWidget. O setupUI marca o widget
-- como botWidget, então ele é destruído sozinho ao parar/recarregar o bot.
targetHudLabel = setupUI([[
Label
  id: targetHud
  font: verdana-11px-rounded
  color: red
  text-auto-resize: true
  phantom: true
  text: ""
]], g_ui.getRootWidget())

local targetLabel = targetHudLabel
targetLabel:setPosition({x = 450, y = 30})
targetLabel:hide()

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
