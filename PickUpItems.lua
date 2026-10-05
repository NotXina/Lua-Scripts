-- ============================================================================
-- PICK-UP ITENS (CATAR ITENS DO CHÃO)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.pickEnabled = storage.pickEnabled or 0
storage.pickUp = type(storage.pickUp) == "table" and storage.pickUp or {3725, 3723}
storage.containerpickUp = type(storage.containerpickUp) == "table" and storage.containerpickUp or {5926}
storage.pickRange = type(storage.pickRange) == "number" and storage.pickRange or 1

if pickupSetupWindow then pickupSetupWindow:destroy() end

g_ui.loadUIFromString([[
PickupSetupWindow < MainWindow
  text: Pick-Up Setup
  size: 210 310
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true
  Label
    width: 190
    text-align: center
    text: Pegar Somente
    margin-top: 5
  HorizontalSeparator
    width: 190
    margin-top: 3
  Panel
    id: pickOnlyPanel
    width: 190
    height: 90
    margin-top: 3
  HorizontalSeparator
    width: 190
    margin-top: 5
  Label
    width: 190
    text-align: center
    text: Catar P/ Container
    margin-top: 5
  HorizontalSeparator
    width: 190
    margin-top: 3
  Panel
    id: pickContainerPanel
    width: 190
    height: 50
    margin-top: 3
  HorizontalSeparator
    width: 190
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

pickupSetupWindow = UI.createWindow('PickupSetupWindow', g_ui.getRootWidget())
pickupSetupWindow:hide()

local pickUpContainer = UI.Container(function(widget, items)
  storage.pickUp = items
end, true)
pickUpContainer:setParent(pickupSetupWindow.pickOnlyPanel)
pickUpContainer:fill('parent')
pickUpContainer:setItems(storage.pickUp)

local containerpickUpContainer = UI.Container(function(widget, items)
  storage.containerpickUp = items
end, true)
containerpickUpContainer:setParent(pickupSetupWindow.pickContainerPanel)
containerpickUpContainer:fill('parent')
containerpickUpContainer:setItems(storage.containerpickUp)

pickupSetupWindow.closeButton.onClick = function()
  pickupSetupWindow:hide()
end

local pickUI = setupUI([[
Panel
  height: 38
  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    width: 130
    height: 18
    text: Pick-Up Itens
  Button
    id: btnSetup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
  Label
    id: rangeLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 3
    height: 17
    text-auto-resize: true
  HorizontalScrollBar
    id: rangeScroll
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 5
    height: 15
    minimum: 1
    maximum: 7
    step: 1
]], parent)

pickUI.rangeScroll:setValue(storage.pickRange)
pickUI.rangeLabel:setText("Range: " .. storage.pickRange .. " tiles")
pickUI.rangeScroll.onValueChange = function(widget, value)
  storage.pickRange = value
  pickUI.rangeLabel:setText("Range: " .. value .. " tiles")
end

pickUI.btnSetup.onClick = function()
  pickupSetupWindow:show()
  pickupSetupWindow:raise()
  pickupSetupWindow:focus()
end

macro(200, function()
  if storage.pickEnabled ~= 1 or freecap() < 150 or not storage.pickUp[1] then return end

  local pickMap = {}
  for _, item in ipairs(storage.pickUp) do
    local id = type(item) == "table" and item.id or item
    if id then pickMap[id] = true end
  end

  local destBpMap = {}
  for _, bp in ipairs(storage.containerpickUp) do
    local id = type(bp) == "table" and bp.id or bp
    if id then destBpMap[id] = true end
  end

  local pPos = pos()
  local r = storage.pickRange

  for x = -r, r do
    for y = -r, r do
      local tile = g_map.getTile({x = pPos.x + x, y = pPos.y + y, z = pPos.z})
      if tile then
        for _, item in ipairs(tile:getItems() or {}) do
          if item and pickMap[item:getId()] then
            for idx = 0, 15 do
              local container = g_game.getContainer(idx)
              if container then
                local cItem = container:getContainerItem()
                if cItem and destBpMap[cItem:getId()] then
                  if container:getItemsCount() < container:getCapacity() then
                    g_game.move(item, container:getSlotPosition(container:getItemsCount()), item:getCount())
                    delay(250)
                    return
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end)

local pickIconWidget = nil
local function pickSetEnabled(val)
  storage.pickEnabled = val and 1 or 0
  pickUI.status:setOn(val)
  if pickIconWidget then pickIconWidget.setOn(val) end
end

pickUI.status:setOn(storage.pickEnabled == 1)
pickUI.status.onClick = function()
  pickSetEnabled(storage.pickEnabled ~= 1)
end

addIcon("PickupIcon", {
  item = { id = 3492, count = 1 },
  text = "Pick-Up",
  switchable = true,
}, function(widget, isOn_)
  pickIconWidget = widget
  storage.pickEnabled = isOn_ and 1 or 0
  pickUI.status:setOn(isOn_)
end)
