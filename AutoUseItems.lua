-- ============================================================================
-- AUTO USE ITEMS (USA TODOS OS ITENS FORA DE PZ EM INTERVALOS CONFIGURAVEIS)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local settingsKey = "autoUseItemsSettings"
local defaultItems = {3215, 9642, 3726, 11454, 945, 10293, 10306, 10316, 11455}

storage[settingsKey] = type(storage[settingsKey]) == "table" and storage[settingsKey] or {}
local settings = storage[settingsKey]

if type(settings.enabled) ~= "boolean" then settings.enabled = false end
if type(settings.timeMinutes) ~= "number" then settings.timeMinutes = 31 end
if type(settings.items) ~= "table" then settings.items = defaultItems end
settings.timeMinutes = math.max(1, math.min(60, settings.timeMinutes))

-- Mantem os 15 slots numericos, inclusive os vazios, para nao perder itens
-- que estejam depois de um slot em branco.
for i = 1, 15 do
  local value = settings.items[i]
  if type(value) == "table" then value = value.id end
  settings.items[i] = tonumber(value) or 0
end

if autoUseItemsWindow then autoUseItemsWindow:destroy() end

g_ui.loadUIFromString([[
AutoUseItemsWindow < MainWindow
  text: Auto Use Items Setup
  size: 230 255
  @onEscape: self:hide()

  Label
    id: intervalLabel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Intervalo: 31 minutos

  HorizontalScrollBar
    id: intervalScroll
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 1
    maximum: 60
    step: 1

  Label
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: center
    text: So usa os itens quando estiver fora de PZ

  HorizontalSeparator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 7

  Label
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: center
    text: Itens usados na ordem dos slots

  ItemsRow
    id: itemsRow1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3

  ItemsRow
    id: itemsRow2
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 2

  ItemsRow
    id: itemsRow3
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 2

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

autoUseItemsWindow = UI.createWindow('AutoUseItemsWindow', g_ui.getRootWidget())
autoUseItemsWindow:hide()

local autoUseItemsUI = setupUI([[
Panel
  height: 20

  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    width: 130
    height: 18
    text: Usar Itens: 31m

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

local function millis()
  if type(now) == "number" then return now end
  if g_clock and type(g_clock.millis) == "function" then return g_clock.millis() end
  return os.time() * 1000
end

local function updateText()
  local minutes = settings.timeMinutes
  local suffix = minutes == 1 and " minuto" or " minutos"
  autoUseItemsWindow.intervalLabel:setText("Intervalo: " .. minutes .. suffix)
  autoUseItemsUI.status:setText("Usar Itens: " .. minutes .. "m")
end

local itemRows = {
  autoUseItemsWindow.itemsRow1,
  autoUseItemsWindow.itemsRow2,
  autoUseItemsWindow.itemsRow3
}

for i = 1, 15 do
  local slotIndex = i
  local rowIndex = math.floor((slotIndex - 1) / 5) + 1
  local childIndex = ((slotIndex - 1) % 5) + 1
  local itemWidget = itemRows[rowIndex]:getChildByIndex(childIndex)

  itemWidget.onItemChange = function(widget)
    settings.items[slotIndex] = widget:getItemId() or 0
  end
  itemWidget:setItemId(settings.items[slotIndex])
end

local nextCycleAt = nil
local cycleRunning = false
local cycleItems = {}
local cycleItemIndex = 1
local nextItemAt = nil

local function clearActiveCycle()
  cycleRunning = false
  cycleItems = {}
  cycleItemIndex = 1
  nextItemAt = nil
end

local function resetCycle(useSoon)
  clearActiveCycle()
  if not settings.enabled then
    nextCycleAt = nil
    return
  end

  if useSoon then
    nextCycleAt = millis() + 1000
  else
    nextCycleAt = millis() + (settings.timeMinutes * 60000)
  end
end

local function finishCycle()
  clearActiveCycle()
  if settings.enabled then
    -- O intervalo seguinte comeca depois que o ultimo item foi usado.
    nextCycleAt = millis() + (settings.timeMinutes * 60000)
  else
    nextCycleAt = nil
  end
end

local function startCycle()
  cycleItems = {}

  -- Percorre por indice para manter a ordem e nao parar em slots vazios.
  for i = 1, 15 do
    local itemId = tonumber(settings.items[i]) or 0
    if itemId > 0 then
      table.insert(cycleItems, itemId)
    end
  end

  cycleItemIndex = 1
  if #cycleItems == 0 then
    finishCycle()
    return
  end

  cycleRunning = true
  nextCycleAt = nil
  nextItemAt = millis()
end

local function processActiveCycle()
  if not cycleRunning or isInPz() then return end

  local timestamp = millis()
  if timestamp < nextItemAt then return end

  local itemId = cycleItems[cycleItemIndex]
  if not itemId then
    finishCycle()
    return
  end

  -- Esta chamada so e alcancada depois da verificacao de PZ acima.
  use(itemId)
  cycleItemIndex = cycleItemIndex + 1

  if cycleItemIndex > #cycleItems then
    finishCycle()
  else
    nextItemAt = timestamp + 500
  end
end

autoUseItemsWindow.intervalScroll.onValueChange = function(_, value)
  settings.timeMinutes = value
  updateText()
  resetCycle(false)
end

autoUseItemsWindow.intervalScroll:setValue(settings.timeMinutes)
updateText()

autoUseItemsWindow.closeButton.onClick = function()
  autoUseItemsWindow:hide()
end

autoUseItemsUI.setup.onClick = function()
  autoUseItemsWindow:show()
  autoUseItemsWindow:raise()
  autoUseItemsWindow:focus()
end

autoUseItemsUI.status:setOn(settings.enabled)
autoUseItemsUI.status.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
  resetCycle(settings.enabled)
end

-- Ao recarregar o script ligado, inicia um novo ciclo em um segundo.
resetCycle(settings.enabled)

macro(500, function()
  if not settings.enabled then return end

  if cycleRunning then
    -- Em PZ, processActiveCycle apenas espera sem criar schedules recursivos.
    processActiveCycle()
    return
  end

  if isInPz() or not nextCycleAt then return end
  if millis() >= nextCycleAt then
    startCycle()
    processActiveCycle()
  end
end)
