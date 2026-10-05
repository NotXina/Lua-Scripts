-- ============================================================================
-- STAMINA ITEMS (USO AUTOMÁTICO DE REGEN DE STAMINA)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local panelName = "staminaItemsUser"
storage[panelName] = storage[panelName] or { min = 0, max = 40, items = {11588} }
if type(storage[panelName].items) ~= "table" then storage[panelName].items = {11588} end
storage.staminaEnabled = storage.staminaEnabled or 0

if staminaSetupWindow then staminaSetupWindow:destroy() end

g_ui.loadUIFromString([[
StaminaSetupWindow < MainWindow
  text: Stamina Setup
  size: 220 200
  @onEscape: self:hide()
  Label
    id: lblRange
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: 0 <= Stamina <= 40
  HorizontalScrollBar
    id: scroll1
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-top: 5
    margin-right: 2
    minimum: 0
    maximum: 42
    step: 1
  HorizontalScrollBar
    id: scroll2
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.top
    margin-left: 2
    minimum: 0
    maximum: 42
    step: 1
  HorizontalSeparator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
  Label
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: center
    text: Itens de Stamina
    margin-top: 5
  ItemsRow
    id: items
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
  HorizontalSeparator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: closeButton.top
    margin-bottom: 8
  Button
    id: closeButton
    text: Close
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
]])

staminaSetupWindow = UI.createWindow('StaminaSetupWindow', g_ui.getRootWidget())
staminaSetupWindow:hide()

local function updateText()
  staminaSetupWindow.lblRange:setText(storage[panelName].min .. " <= Stamina <= " .. storage[panelName].max)
end

staminaSetupWindow.scroll1:setValue(storage[panelName].min)
staminaSetupWindow.scroll2:setValue(storage[panelName].max)
updateText()

staminaSetupWindow.scroll1.onValueChange = function(w, v)
  storage[panelName].min = math.min(v, storage[panelName].max)
  if storage[panelName].min ~= v then w:setValue(storage[panelName].min) end
  updateText()
end
staminaSetupWindow.scroll2.onValueChange = function(w, v)
  storage[panelName].max = math.max(v, storage[panelName].min)
  if storage[panelName].max ~= v then w:setValue(storage[panelName].max) end
  updateText()
end

for i = 1, 5 do
  staminaSetupWindow.items:getChildByIndex(i).onItemChange = function(w)
    storage[panelName].items[i] = w:getItemId()
  end
  staminaSetupWindow.items:getChildByIndex(i):setItemId(storage[panelName].items[i])
end

staminaSetupWindow.closeButton.onClick = function()
  staminaSetupWindow:hide()
end

local staminaUI = setupUI([[
Panel
  height: 20
  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    width: 130
    height: 18
    text: Stamina Items
  Button
    id: btnSetup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

staminaUI.btnSetup.onClick = function()
  staminaSetupWindow:show()
  staminaSetupWindow:raise()
  staminaSetupWindow:focus()
end

macro(1000, function()
  if storage.staminaEnabled ~= 1 then return end
  local stHours = stamina() / 60
  if stHours < storage[panelName].min or stHours > storage[panelName].max then return end

  for _, itemId in ipairs(storage[panelName].items) do
    if itemId and itemId >= 100 then
      local it = findItem(itemId)
      if it then
        g_game.use(it)
        delay(1000)
        return
      end
    end
  end
end)

local staminaIconWidget = nil
local function staminaSetEnabled(val)
  storage.staminaEnabled = val and 1 or 0
  staminaUI.status:setOn(val)
  if staminaIconWidget then staminaIconWidget.setOn(val) end
end

staminaUI.status:setOn(storage.staminaEnabled == 1)
staminaUI.status.onClick = function()
  staminaSetEnabled(storage.staminaEnabled ~= 1)
end

addIcon("StaminaIcon", {
  item = { id = 11588, count = 1 },
  text = "Stamina",
  switchable = true,
}, function(widget, isOn_)
  staminaIconWidget = widget
  storage.staminaEnabled = isOn_ and 1 or 0
  staminaUI.status:setOn(isOn_)
end)
