-- ============================================================================
-- SMART RING SWAPPER (RING INVERTIDO - COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.smartRing = storage.smartRing or {
  enabled = false,
  secRingId = 14557,
  hpEquip = 85,
  mpEquip = 60
}
local config = storage.smartRing
local eRingId = 3051 -- Energy Ring fixo

if smartRingWindow then smartRingWindow:destroy() end

g_ui.loadUIFromString([[
SmartRingWindow < MainWindow
  text: Smart Ring Setup
  size: 210 200
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Anel Secundario (Normal)
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
    id: hpLabel
    text-align: center
    text: Equipa Energy se HP <= 85%
    margin-top: 5

  HorizontalScrollBar
    id: hpScroll
    minimum: 1
    maximum: 100
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

smartRingWindow = UI.createWindow('SmartRingWindow', g_ui.getRootWidget())
smartRingWindow:hide()

smartRingWindow.ringSlot:setItemId(config.secRingId)
smartRingWindow.ringSlot.onItemChange = function(w)
  config.secRingId = w:getItemId()
end

smartRingWindow.hpScroll:setValue(config.hpEquip)
smartRingWindow.hpLabel:setText("Equipa Energy se HP <= " .. config.hpEquip .. "%")
smartRingWindow.hpScroll.onValueChange = function(w, v)
  config.hpEquip = v
  smartRingWindow.hpLabel:setText("Equipa Energy se HP <= " .. v .. "%")
end

smartRingWindow.closeButton.onClick = function()
  smartRingWindow:hide()
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
    !text: tr('Smart Ring')

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
  smartRingWindow:show()
  smartRingWindow:raise()
  smartRingWindow:focus()
end

macro(400, function()
  if not config.enabled then return end

  local hp = hppercent()
  local mp = manapercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local configuredRing = config.secRingId or 14557

  if hp <= config.hpEquip or (hp > config.hpEquip and mp >= config.mpEquip) then
    if currentRingId ~= eRingId then
      local ringItem = findItem(eRingId)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500)
      end
    end
  elseif hp > config.hpEquip and mp < config.mpEquip then
    if configuredRing > 0 and currentRingId ~= configuredRing then
      local ringItem = findItem(configuredRing)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500)
      end
    end
  end
end)
