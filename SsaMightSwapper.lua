-- ============================================================================
-- SMART SSA & MIGHT RING SWAPPER (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.ssaMightSettings = storage.ssaMightSettings or {
  enabled = false,
  ssaId = 3081,
  mightRingId = 3048,
  minHp = 65
}
local config = storage.ssaMightSettings

if ssaMightWindow then ssaMightWindow:destroy() end

g_ui.loadUIFromString([[
SsaMightWindow < MainWindow
  text: SSA & Might Ring Setup
  size: 210 210
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    id: hpLabel
    text-align: center
    text: Equipa se HP <= 65%
    margin-top: 5

  HorizontalScrollBar
    id: hpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 3

  HorizontalSeparator
    margin-top: 8

  Label
    text-align: center
    text: Slots de Itens (SSA / Might)
    margin-top: 3

  Panel
    height: 40
    margin-top: 5

    BotItem
      id: ssaSlot
      anchors.left: parent.left
      anchors.top: parent.top
      margin-left: 35
      width: 34
      height: 34

    BotItem
      id: mightSlot
      anchors.right: parent.right
      anchors.top: parent.top
      margin-right: 35
      width: 34
      height: 34

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

ssaMightWindow = UI.createWindow('SsaMightWindow', g_ui.getRootWidget())
ssaMightWindow:hide()

ssaMightWindow.hpScroll:setValue(config.minHp or 65)
ssaMightWindow.hpLabel:setText("Equipa se HP <= " .. (config.minHp or 65) .. "%")
ssaMightWindow.hpScroll.onValueChange = function(w, v)
  config.minHp = v
  ssaMightWindow.hpLabel:setText("Equipa se HP <= " .. v .. "%")
end

ssaMightWindow.ssaSlot:setItemId(config.ssaId or 3081)
ssaMightWindow.ssaSlot.onItemChange = function(w)
  config.ssaId = w:getItemId()
end

ssaMightWindow.mightSlot:setItemId(config.mightRingId or 3048)
ssaMightWindow.mightSlot.onItemChange = function(w)
  config.mightRingId = w:getItemId()
end

ssaMightWindow.closeButton.onClick = function()
  ssaMightWindow:hide()
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
    !text: tr('SSA & Might')

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
  ssaMightWindow:show()
  ssaMightWindow:raise()
  ssaMightWindow:focus()
end

macro(50, function()
  if not config.enabled then return end
  local hp = hppercent()

  if hp <= (config.minHp or 65) then
    local ssa = findItem(config.ssaId or 3081)
    local curNeck = getNeck()
    if ssa and (not curNeck or curNeck:getId() ~= config.ssaId) then
      g_game.equipItemId(config.ssaId)
    end

    local mRing = findItem(config.mightRingId or 3048)
    local curRing = getFinger()
    if mRing and (not curRing or curRing:getId() ~= config.mightRingId) then
      g_game.equipItemId(config.mightRingId)
    end
  end
end)
