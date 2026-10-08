-- ============================================================================
-- ÍCONES CAVEBOT & TARGETBOT (COM INDICADOR ON/OFF LEVE)
-- ============================================================================
-- Posicao fixa: canto superior esquerdo do mapa, CaveBot em cima e TargetBot
-- embaixo (x/y relativos ao painel do mapa, 0.0 - 1.0). O OTCv8 guarda a
-- posicao arrastada em storage._icons[id]; a entrada e limpa antes do
-- addIcon para os icones voltarem SEMPRE para ca ao recarregar o script.
local ICON_POS = {
  cI = {x = 0.01, y = 0.05}, -- CaveBot
  tI = {x = 0.01, y = 0.25}, -- TargetBot
}

storage._icons = storage._icons or {}
for id in pairs(ICON_POS) do
  storage._icons[id] = nil
end

local cIcon = addIcon("cI", {text = "Cave\nBot", switchable = false, moveable = true,
                             x = ICON_POS.cI.x, y = ICON_POS.cI.y}, function()
  if CaveBot.isOff() then CaveBot.setOn() else CaveBot.setOff() end
end)
cIcon:setSize({height = 30, width = 50})
cIcon.text:setFont('verdana-11px-rounded')

local tIcon = addIcon("tI", {text = "Target\nBot", switchable = false, moveable = true,
                             x = ICON_POS.tI.x, y = ICON_POS.tI.y}, function()
  if TargetBot.isOff() then TargetBot.setOn() else TargetBot.setOff() end
end)
tIcon:setSize({height = 30, width = 50})
tIcon.text:setFont('verdana-11px-rounded')

-- Atualização leve a cada 300ms (Sem lag de renderização)
macro(300, function()
  if CaveBot.isOn() then
    cIcon.text:setColoredText({"CaveBot\n", "white", "ON", "green"})
  else
    cIcon.text:setColoredText({"CaveBot\n", "white", "OFF", "red"})
  end

  if TargetBot.isOn() then
    tIcon.text:setColoredText({"Target\n", "white", "ON", "green"})
  else
    tIcon.text:setColoredText({"Target\n", "white", "OFF", "red"})
  end
end)
