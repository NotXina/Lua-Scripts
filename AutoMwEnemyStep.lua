-- ============================================================================
-- AUTO MW NO STEP DO INIMIGO (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.mwEnemyStep = storage.mwEnemyStep or {
  enabled = false,
  mwId = 3180,
  maxDistance = 3
}
local config = storage.mwEnemyStep
-- Normaliza o alcance para configs salvos antes do slider existir.
config.maxDistance = type(config.maxDistance) == "number" and config.maxDistance or 3

-- Alcance maximo (SQMs) para jogar a MW no SQM que o inimigo deixou.
-- Escolhido pela barra variavel do Setup (padrao 3). Mantenha baixo: com a
-- runa longe demais o server OBRIGA o personagem a andar ate o SQM antes de
-- usar. Com 3 o char nunca sai do lugar.

if mwStepWindow then mwStepWindow:destroy() end

g_ui.loadUIFromString([[
MwStepWindow < MainWindow
  text: MW Step Setup
  size: 210 218
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Runa de Magic Wall:
    margin-top: 5

  BotItem
    id: mwSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    width: 34
    height: 34

  HorizontalSeparator
    margin-top: 8

  Label
    text-align: center
    text: Alcance maximo (SQMs):
    margin-top: 5

  HorizontalScrollBar
    id: distScroll
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 3
    width: 160
    height: 15
    minimum: 1
    maximum: 7
    step: 1

  Label
    id: distLabel
    text-align: center
    margin-top: 3
    text: ""

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

mwStepWindow = UI.createWindow('MwStepWindow', g_ui.getRootWidget())
mwStepWindow:hide()

mwStepWindow.mwSlot:setItemId(config.mwId or 3180)
mwStepWindow.mwSlot.onItemChange = function(w)
  config.mwId = w:getItemId()
end

-- Barra variavel do alcance (quantos SQMs a MW pode ser jogada longe do char).
mwStepWindow.distScroll:setValue(config.maxDistance)
mwStepWindow.distLabel:setText("Distancia: " .. config.maxDistance .. " SQMs")
mwStepWindow.distScroll.onValueChange = function(widget, value)
  config.maxDistance = value
  mwStepWindow.distLabel:setText("Distancia: " .. value .. " SQMs")
end

mwStepWindow.closeButton.onClick = function()
  mwStepWindow:hide()
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
    !text: tr('MW Enemy Step')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

ui.setup.onClick = function()
  mwStepWindow:show()
  mwStepWindow:raise()
  mwStepWindow:focus()
end

local function isValidEnemy(creature)
  if not creature or not creature:isPlayer() or creature:isLocalPlayer() then 
    return false 
  end

  local creatureName = creature:getName()
  local lowerName = creatureName:lower()
  local myName = name():lower()
  local shield = creature:getShield() or 0
  local emblem = creature:getEmblem() or 0

  return lowerName ~= myName
    and not isFriend(creatureName)
    and shield < 3
    and emblem ~= 1
end

onCreaturePositionChange(function(creature, newPos, oldPos)
  if not config.enabled then return end

  if isValidEnemy(creature) then
    local localPlayer = g_game.getLocalPlayer()
    if not localPlayer then return end
    local myPosition = localPlayer:getPosition()

    local maxDistance = config.maxDistance or 3
    if oldPos and oldPos.z == myPosition.z
      and getDistanceBetween(myPosition, oldPos) <= maxDistance then
      local tile = g_map.getTile(oldPos)
      if tile and tile:isWalkable() then
        local target = tile:getTopUseThing() or tile:getGround()
        if target then
          useWith(config.mwId or 3180, target)
        end
      end
    end
  end
end)
