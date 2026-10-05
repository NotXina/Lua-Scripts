-- ============================================================================
-- SAFE SD / UE (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.safeSdMasFrigo = storage.safeSdMasFrigo or {
  enabled = false,
  Spell = "exevo gran mas frigo",
  safeRange = 8,
  targetDistance = 4
}
local settings = storage.safeSdMasFrigo

if safeSdWindow then safeSdWindow:destroy() end

g_ui.loadUIFromString([[
SafeSdWindow < MainWindow
  text: Safe SD/UE Setup
  size: 210 180
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Magia de Area (UE):
    margin-top: 5

  TextEdit
    id: spellText
    margin-top: 3
    text-align: center

  HorizontalSeparator
    margin-top: 8

  Label
    id: rangeLabel
    text-align: center
    text: Distancia Maxima UE: 4 SQMs
    margin-top: 3

  HorizontalScrollBar
    id: distScroll
    minimum: 1
    maximum: 7
    step: 1
    margin-top: 3

  HorizontalSeparator
    margin-top: 8

  Button
    id: closeButton
    text: Close
    font: cipsoftFont
    margin-top: 5
    margin-left: 145
    width: 45
    height: 21
]])

safeSdWindow = UI.createWindow('SafeSdWindow', g_ui.getRootWidget())
safeSdWindow:hide()

safeSdWindow.spellText:setText(settings.Spell or "exevo gran mas frigo")
safeSdWindow.spellText.onTextChange = function(w, text)
  settings.Spell = text
end

safeSdWindow.distScroll:setValue(settings.targetDistance or 4)
safeSdWindow.rangeLabel:setText("Distancia Maxima UE: " .. (settings.targetDistance or 4) .. " SQMs")
safeSdWindow.distScroll.onValueChange = function(w, v)
  settings.targetDistance = v
  safeSdWindow.rangeLabel:setText("Distancia Maxima UE: " .. v .. " SQMs")
end

safeSdWindow.closeButton.onClick = function()
  safeSdWindow:hide()
end

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Safe SD/UE')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.setup.onClick = function()
  safeSdWindow:show()
  safeSdWindow:raise()
  safeSdWindow:focus()
end

-- Verifica se tem amigo (party, guild ou lista de amigos) perto o bastante
-- para ser atingido pela área. Não usa isSafe()/isFriend() puros do vBot
-- porque isFriend() NÃO reconhece membro de guild (sem emblema) como amigo,
-- e só reconhece membro de party se a opção "Group Members" da Player List
-- do vBot estiver ligada. Checar o shield (party) e o emblem (guild/ally)
-- diretamente evita soltar UE em cima de guild/party, igual aos outros
-- scripts deste repositório (AttackPlayersLowestHp, UhNoTime, etc).
local function hasFriendNearby(range)
  local pPos = pos()
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      local specPos = spec:getPosition()
      if specPos.z == pPos.z and getDistanceBetween(pPos, specPos) <= range then
        if spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName()) then
          return true
        end
      end
    end
  end
  return false
end

macro(1000, function()
  if not settings.enabled then return end
  local target = g_game.getAttackingCreature()
  if not target then return end

  local maxDist = settings.targetDistance or 4
  local safeRange = settings.safeRange or 8

  if not hasFriendNearby(safeRange) and getDistanceBetween(pos(), target:getPosition()) <= maxDist then
    local spell = settings.Spell
    if spell and spell:match("%S") then
      say(spell)
    end
  else
    useWith(3155, target)
  end
end)

