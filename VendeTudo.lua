-- ============================================================================
-- VENDE TUDO (OTIMIZADO COM TABELA HASH O(1))
-- Vende os itens da lista usando a Sell Wand sem travamentos
-- ============================================================================

local sellWand = 7426
storage.sellEnabled = storage.sellEnabled or 0
if type(storage.ItemsToSell) ~= "table" then
  storage.ItemsToSell = {
    822, 7412, 7388, 3554, 7423, 7422, 32208, 32209, 8074, 821, 823,
    32187, 32188, 16126, 3364, 3281, 3366, 3071, 3280, 3420, 3079,
    3392, 7402, 3386, 32185, 32186, 3360, 3342, 3370, 7430, 8057,
    3414, 32180, 32179, 32178, 3063, 826, 7382,
    41971, 41968, 41969, 41970, 41966, 41965, 41967
  }
end

if sellSetupWindow then sellSetupWindow:destroy() end

g_ui.loadUIFromString([[
SellSetupWindow < MainWindow
  text: Vende Tudo - Setup
  size: 210 180
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true
  Label
    width: 190
    text-align: center
    text: Itens para Vender
    margin-top: 5
  HorizontalSeparator
    width: 190
    margin-top: 3
  Panel
    id: sellContainer
    width: 190
    height: 70
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

sellSetupWindow = UI.createWindow('SellSetupWindow', g_ui.getRootWidget())
sellSetupWindow:hide()

local sellContainer = UI.Container(function(widget, items)
  storage.ItemsToSell = items
end, true)
sellContainer:setParent(sellSetupWindow.sellContainer)
sellContainer:fill('parent')
sellContainer:setItems(storage.ItemsToSell)

sellSetupWindow.closeButton.onClick = function()
  sellSetupWindow:hide()
end

local sellUI = setupUI([[
Panel
  height: 20
  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    width: 130
    height: 18
    text: Vende Tudo
  Button
    id: btnSetup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

sellUI.btnSetup.onClick = function()
  sellSetupWindow:show()
  sellSetupWindow:raise()
  sellSetupWindow:focus()
end

macro(200, function()
  if storage.sellEnabled ~= 1 then return end

  local sellMap = {}
  for _, it in ipairs(storage.ItemsToSell) do
    local id = type(it) == "table" and it.id or it
    if id then sellMap[id] = true end
  end

  for idx = 0, 15 do
    local container = g_game.getContainer(idx)
    if container then
      for _, item in ipairs(container:getItems() or {}) do
        if sellMap[item:getId()] then
          useWith(sellWand, item)
          delay(400)
          return
        end
      end
    end
  end
end)

local sellIconWidget = nil
local function sellSetEnabled(val)
  storage.sellEnabled = val and 1 or 0
  sellUI.status:setOn(val)
  if sellIconWidget then sellIconWidget.setOn(val) end
end

sellUI.status:setOn(storage.sellEnabled == 1)
sellUI.status.onClick = function()
  sellSetEnabled(storage.sellEnabled ~= 1)
end

addIcon("SellIcon", {
  item = { id = sellWand, count = 1 },
  text = "Sell",
  switchable = true,
}, function(widget, isOn_)
  sellIconWidget = widget
  storage.sellEnabled = isOn_ and 1 or 0
  sellUI.status:setOn(isOn_)
end)
