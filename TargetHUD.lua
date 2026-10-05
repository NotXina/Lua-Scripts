-- ============================================================================
-- INIMIGO TARGET HUD
-- Mostra o Nick, Vida % e Distância do seu alvo no topo da tela
-- ============================================================================

-- Destrói o label anterior para não duplicar ao recarregar o script
if targetHudLabel then
  targetHudLabel:destroy()
  targetHudLabel = nil
end

-- O widget precisa ser criado no rootWidget, e nao dentro do painel do bot.
-- Assim ele permanece sobre a tela do jogo e continua visivel mesmo quando
-- ainda nao existe um alvo.
targetHudLabel = setupUI([[
Panel
  id: targetHud
  width: 420
  height: 24
  background-color: #101010dd
  border: 1 #ff5555
  phantom: true
  anchors.top: parent.top
  anchors.horizontalCenter: parent.horizontalCenter
  margin-top: 35

  Label
    id: text
    anchors.fill: parent
    font: verdana-11px-rounded
    color: #ff5555
    text-align: center
    text: "TARGET HUD: nenhum alvo"
]], g_ui.getRootWidget())

local targetLabel = targetHudLabel.text
targetHudLabel:show()
targetHudLabel:raise()

macro(100, "Target HUD", function()
  local target = g_game.getAttackingCreature()
  local targetPos = target and target:getPosition()
  local myPos = pos()

  if target and targetPos and myPos then
    local hp = math.floor(tonumber(target:getHealthPercent()) or 0)
    local dist = math.floor(getDistanceBetween(myPos, targetPos) or 0)
    local targetType = target:isPlayer() and "PLAYER" or "CREATURE"
    targetLabel:setText(string.format("ALVO %s: %s | HP: %d%% | DIST: %d",
      targetType, target:getName() or "?", hp, dist))
  else
    targetLabel:setText("TARGET HUD: ataque um alvo para ver HP e distancia")
  end

  targetHudLabel:show()
end)
