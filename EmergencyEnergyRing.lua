-- ============================================================================
-- EMERGENCY ENERGY RING SWAPPER (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.emergencyRing = storage.emergencyRing or {
  enabled = false,
  secRingId = 3048,
  equipHp = 60,
  unequipHp = 80
}
local config = storage.emergencyRing
local eRingId = 3051

if emergencyRingWindow then emergencyRingWindow:destroy() end

g_ui.loadUIFromString([[
EmergencyRingWindow < MainWindow
  text: Emergency Ring Setup
  size: 210 230
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Anel Principal (Normal)
    margin-top: 5

  HorizontalSeparator
    margin-top: 3

  BotItem
    id: ringSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    width: 34
    height: 34

  HorizontalSeparator
    margin-top: 8

  Label
    id: equipLabel
    text-align: center
    text: Equipa Energy se HP <= 60%
    margin-top: 3

  HorizontalScrollBar
    id: equipScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 2

  Label
    id: unequipLabel
    text-align: center
    text: Tira Energy se HP >= 80%
    margin-top: 5

  HorizontalScrollBar
    id: unequipScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 2

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

emergencyRingWindow = UI.createWindow('EmergencyRingWindow', g_ui.getRootWidget())
emergencyRingWindow:hide()

emergencyRingWindow.ringSlot:setItemId(config.secRingId)
emergencyRingWindow.ringSlot.onItemChange = function(w)
  config.secRingId = w:getItemId()
end

emergencyRingWindow.equipScroll:setValue(config.equipHp)
emergencyRingWindow.equipLabel:setText("Equipa Energy se HP <= " .. config.equipHp .. "%")
emergencyRingWindow.equipScroll.onValueChange = function(w, v)
  config.equipHp = v
  emergencyRingWindow.equipLabel:setText("Equipa Energy se HP <= " .. v .. "%")
end

emergencyRingWindow.unequipScroll:setValue(config.unequipHp)
emergencyRingWindow.unequipLabel:setText("Tira Energy se HP >= " .. config.unequipHp .. "%")
emergencyRingWindow.unequipScroll.onValueChange = function(w, v)
  config.unequipHp = v
  emergencyRingWindow.unequipLabel:setText("Tira Energy se HP >= " .. v .. "%")
end

emergencyRingWindow.closeButton.onClick = function()
  emergencyRingWindow:hide()
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
    !text: tr('Emergency Ring')

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
  emergencyRingWindow:show()
  emergencyRingWindow:raise()
  emergencyRingWindow:focus()
end

macro(250, function()
  if not config.enabled then return end

  local hp = hppercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local normalRingId = config.secRingId or 0

  if hp <= config.equipHp then
    if currentRingId ~= eRingId then
      local eRingItem = findItem(eRingId)
      if eRingItem then
        moveToSlot(eRingItem, SlotFinger)
        delay(400)
      end
    end
  elseif hp >= config.unequipHp then
    if normalRingId > 0 and currentRingId ~= normalRingId then
      local normalRingItem = findItem(normalRingId)
      if normalRingItem then
        moveToSlot(normalRingItem, SlotFinger)
        delay(400)
      end
    end
  end
end)
