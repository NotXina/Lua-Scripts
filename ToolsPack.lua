-- ============================================================================
--                        TOOLS PACK (OTIMIZADO - ZERO LAG)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

-- ============================================================================
-- 1. PICK-UP ITENS (CATAR ITENS DO CHÃO)
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

-- Macro Otimizado de Pick-Up (200ms com busca rápida O(1))
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
}, function(widget, isOn_)
  pickIconWidget = widget
  pickSetEnabled(isOn_)
end)

schedule(100, function()
  if pickIconWidget then
    pickIconWidget.setOn(storage.pickEnabled == 1)
  end
end)

-- ============================================================================
-- 2. STAMINA ITEMS
-- ============================================================================
local function staminaItems(parentPanel)
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
]], parentPanel)

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
  }, function(widget, isOn_)
    staminaIconWidget = widget
    staminaSetEnabled(isOn_)
  end)

  schedule(100, function()
    if staminaIconWidget then
      staminaIconWidget.setOn(storage.staminaEnabled == 1)
    end
  end)
end

staminaItems(parent)

-- ============================================================================
-- 3. VENDE TUDO (OTIMIZADO COM TABELA HASH O(1))
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
}, function(widget, isOn_)
  sellIconWidget = widget
  sellSetEnabled(isOn_)
end)

schedule(100, function()
  if sellIconWidget then
    sellIconWidget.setOn(storage.sellEnabled == 1)
  end
end)

-- ============================================================================
-- 4. AUTO FOLLOW (PATHFINDING OTIMIZADO)
-- ============================================================================
addSeparator()
addLabel("", "Auto Follow"):setColor("teal")
addSeparator()

local leaderPositions = {}
local leaderDirections = {}
local leader = nil
local lastLeaderFloor = nil
local ropeId = 3003
local standTime = now

local FloorChangers = {
  RopeSpots = { Up = {386}, Down = {} },
  Use = {
    Up = {1948, 5542, 16693, 16692, 1723, 7771, 5102, 5111, 5120, 9556, 8259, 5131, 8261, 5122},
    Down = {435}
  }
}

local function handleUse(pos)
  if not pos or posz() ~= pos.z then return end
  local tile = g_map.getTile(pos)
  if tile and tile:getTopUseThing() then
    g_game.use(tile:getTopUseThing())
  end
end

local function handleRope(pos)
  if not pos or posz() ~= pos.z then return end
  local tile = g_map.getTile(pos)
  if tile and tile:getTopUseThing() then
    useWith(ropeId, tile:getTopUseThing())
  end
end

local floorChangeSelector = {
  RopeSpots = {Up = handleRope, Down = handleRope},
  Use = {Up = handleUse, Down = handleUse}
}

local function handleFloorChange()
  local p = player:getPosition()
  if not p then return false end
  local range = 1

  for _, dir in ipairs({"Down", "Up"}) do
    for changer, data in pairs(FloorChangers) do
      for x = -range, range do
        for y = -range, range do
          local checkPos = {x = p.x + x, y = p.y + y, z = p.z}
          local tile = g_map.getTile(checkPos)
          if tile and tile:getTopUseThing() then
            if table.find(data[dir], tile:getTopUseThing():getId()) then
              floorChangeSelector[changer][dir](checkPos)
              return true
            end
          end
        end
      end
    end
  end
  return false
end

local function levitate(dir)
  turn(dir)
  schedule(150, function()
    say('exani hur "down')
    say('exani hur "up')
  end)
end

ultimateFollow = macro(150, "Follow", function()
  local myPos = player:getPosition()
  if not myPos then return end

  if not leader then
    local leaderPos = leaderPositions[posz()]
    if leaderPos and getDistanceBetween(myPos, leaderPos) > 0 then
      autoWalk(leaderPos, 70, {ignoreNonPathable = true, precision = 0})
      delay(200)
      return
    end
    if handleFloorChange() then return end
    local dir = leaderDirections[posz()]
    if dir then levitate(dir) end
  else
    local lpos = leader:getPosition()
    if not lpos then return end
    local dist = getDistanceBetween(myPos, lpos)

    if dist > 1 then
      local params = {ignoreNonPathable = true, precision = 1, ignoreCreatures = true}
      autoWalk(lpos, 40, params)
      delay(150)
    end
  end
end)

UI.Label("Follow Player:")
UI.TextEdit(storage.followLeader or "Name", function(widget, text)
  storage.followLeader = text
  leader = getCreatureByName(text)
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if ultimateFollow.isOff() or not creature then return end
  local cName = creature:getName()
  if not cName then return end

  if cName == player:getName() then standTime = now; return end
  if not storage.followLeader or cName:lower() ~= storage.followLeader:lower() then return end

  if newPos then
    leaderPositions[newPos.z] = newPos
    lastLeaderFloor = newPos.z
    leader = (newPos.z == posz()) and creature or nil
  else
    leader = nil
  end

  if oldPos and oldPos.z == posz() then
    autoWalk(oldPos, 40, {ignoreNonPathable = 1, precision = 1})
  end
end)

onCreatureAppear(function(creature)
  if ultimateFollow.isOff() or not creature or not storage.followLeader then return end
  local cPos = creature:getPosition()
  if not cPos or cPos.z ~= posz() then return end

  if creature:getName():lower() == storage.followLeader:lower() then
    leader = creature
  end
end)

onCreatureDisappear(function(creature)
  if ultimateFollow.isOff() or not creature or not storage.followLeader then return end
  if creature:getName():lower() == storage.followLeader:lower() then
    leader = nil
  end
end)

addIcon("Follow", {item = {id = 45290, count = 1}, text = "Follow"}, ultimateFollow)
