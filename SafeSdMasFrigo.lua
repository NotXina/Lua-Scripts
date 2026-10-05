-- ============================================================================
-- SAFE SD / UE (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.safeSdMasFrigo = storage.safeSdMasFrigo or {
  enabled = false,
  Spell = "exevo gran mas frigo",
  safeRange = 8
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
    id: safeRangeLabel
    text-align: center
    text: Raio para comparar shield: 8 SQMs
    margin-top: 3

  HorizontalScrollBar
    id: safeRangeScroll
    minimum: 1
    maximum: 8
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

safeSdWindow.safeRangeScroll:setValue(settings.safeRange or 8)
safeSdWindow.safeRangeLabel:setText("Raio para comparar shield: " .. (settings.safeRange or 8) .. " SQMs")
safeSdWindow.safeRangeScroll.onValueChange = function(w, v)
  settings.safeRange = v
  safeSdWindow.safeRangeLabel:setText("Raio para comparar shield: " .. v .. " SQMs")
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

-- A única trava da UE é encontrar, no mesmo andar e dentro do raio,
-- outro jogador cujo shield seja diferente do shield do personagem local.
-- Não há bloqueio separado por guild, party, amizade ou distância do alvo.
local function hasDifferentShieldNearby(range)
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then return false end

  local myShield = localPlayer:getShield() or 0
  local pPos = localPlayer:getPosition()
  for _, spec in ipairs(getSpectators(pPos.z, false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      local specPos = spec:getPosition()
      if specPos.z == pPos.z
        and getDistanceBetween(pPos, specPos) <= range
        and (spec:getShield() or 0) ~= myShield then
        return true
      end
    end
  end
  return false
end

macro(1000, function()
  if not settings.enabled then return end
  local target = g_game.getAttackingCreature()
  if not target then return end

  local safeRange = settings.safeRange or 8

  if not hasDifferentShieldNearby(safeRange) then
    local spell = settings.Spell
    if spell and spell:match("%S") then
      say(spell)
    end
  else
    useWith(3155, target)
  end
end)

