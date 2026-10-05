-- ============================================================================
--                        PUSHMAX (SCROLL DOWN TRIGGER)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

---@diagnostic disable: undefined-global
setDefaultTab("Main")

local panelName = "pushmax"

-- Configuração inicial salva no storage
storage[panelName] = storage[panelName] or {
  enabled = true,
  pushDelay = 1060,
  pushMaxRuneId = 3188,
  mwallBlockId = 2128
}
local config = storage[panelName]

-- Interface principal no painel
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('PUSHMAX [Scroll]')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

ui:setId(panelName)
ui.title:setOn(config.enabled)

ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

-- Janela de Configurações (Setup)
local rootWidget = g_ui.getRootWidget()
local pushWindow = nil

if rootWidget then
  pcall(function()
    pushWindow = UI.createWindow('PushMaxWindow', rootWidget)
    pushWindow:hide()

    pushWindow.closeButton.onClick = function()
      pushWindow:hide()
    end

    local updateDelayText = function()
      pushWindow.delayText:setText("Push Delay: " .. config.pushDelay .. "ms")
    end
    updateDelayText()

    pushWindow.delay.onValueChange = function(scroll, value)
      config.pushDelay = value
      updateDelayText()
    end
    pushWindow.delay:setValue(config.pushDelay)

    pushWindow.runeId.onItemChange = function(widget)
      config.pushMaxRuneId = widget:getItemId()
    end
    pushWindow.runeId:setItemId(config.pushMaxRuneId)

    pushWindow.mwallId.onItemChange = function(widget)
      config.mwallBlockId = widget:getItemId()
    end
    pushWindow.mwallId:setItemId(config.mwallBlockId)
  end)
end

ui.push.onClick = function()
  if pushWindow then
    pushWindow:show()
    pushWindow:raise()
    pushWindow:focus()
  end
end

-- ============================================================================
-- FUNÇÕES DE SUPORTE
-- ============================================================================
local dangerousFields = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire
  [105]  = true,                                -- Poison
  [2122] = true, [2123] = true, [2124] = true  -- Energy
}

local targetTile = nil
local pushTarget = nil

local function resetData()
  local pPos = pos()
  for _, tile in pairs(g_map.getTiles(pPos.z) or {}) do
    local text = tile:getText()
    if text == "TARGET" or text == "DEST" then
      tile:setText('')
    end
  end
  pushTarget = nil
  targetTile = nil
end

local function isFieldPresent(tile)
  if not tile then return false end
  for _, item in ipairs(tile:getItems() or {}) do
    if dangerousFields[item:getId()] then return true end
  end
  return false
end

local function isAdjacent(pos1, pos2)
  if not pos1 or not pos2 or pos1.z ~= pos2.z then return false end
  return getDistanceBetween(pos1, pos2) == 1
end

-- ============================================================================
-- ACIONAMENTO PELO SCROLL DO MOUSE PARA BAIXO
-- ============================================================================
local function handleScrollTrigger()
  if not config.enabled then return end

  local tile = getTileUnderCursor()
  if not tile then return end

  if pushTarget and targetTile then
    resetData()
    return
  end

  local creatures = tile:getCreatures()
  local creature = creatures and creatures[1]

  -- 1º Scroll: Marca o Alvo Inimigo (TARGET)
  if not pushTarget and creature then
    pushTarget = creature
    tile:setText('TARGET')
    if pushTarget.setMarked then
      pushTarget:setMarked('#00FF00')
    end

  -- 2º Scroll: Marca o SQM de Destino ao lado do alvo (DEST)
  elseif not targetTile and pushTarget then
    if not isAdjacent(tile:getPosition(), pushTarget:getPosition()) then
      resetData()
    else
      tile:setText('DEST')
      targetTile = tile
    end
  end
end

onMouseWheel(function(mousePos, direction)
  if direction == MouseWheelDown or direction == 2 or direction == 1 or direction == "down" then
    handleScrollTrigger()
  end
end)

onKeyDown(function(keys)
  local k = keys:lower()
  if k == "mousewheeldown" or k == "wheeldown" then
    handleScrollTrigger()
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if not config.enabled or not creature then return end

  if creature:isLocalPlayer() then
    resetData()
  end

  if pushTarget and targetTile and creature == pushTarget then
    local destPos = targetTile:getPosition()
    if newPos and newPos.x == destPos.x and newPos.y == destPos.y and newPos.z == destPos.z then
      resetData()
    end
  end
end)

-- ============================================================================
-- MACRO PRINCIPAL DO PUSHMAX (50ms)
-- ============================================================================
macro(50, function()
  if not config.enabled then return end
  if not pushTarget or not targetTile then return end

  local pushDelay = tonumber(config.pushDelay) or 1060
  local rune = tonumber(config.pushMaxRuneId) or 3188
  local customMwall = tonumber(config.mwallBlockId) or 2128

  local destPos = targetTile:getPosition()
  local targetPos = pushTarget:getPosition()
  if not isAdjacent(destPos, targetPos) then return end

  local tileOfTarget = g_map.getTile(targetPos)
  local timer = targetTile:getTimer() or 0

  if not targetTile:isWalkable() then
    local topThing = targetTile:getTopUseThing()
    local topId = topThing and topThing:getId() or 0

    if topId == 2129 or topId == 2130 or topId == customMwall then
      if timer < (pushDelay + 500) then
        if vBot then vBot.isUsing = true end
        schedule(pushDelay + 700, function()
          if vBot then vBot.isUsing = false end
        end)
      end
      if timer > pushDelay then
        return
      end
    else
      resetData()
      return
    end
  end

  local targetTop = tileOfTarget and tileOfTarget:getTopUseThing()
  if targetTop and not targetTop:isNotMoveable() and timer < (pushDelay + 500) then
    useWith(rune, pushTarget)
    return
  end

  if isFieldPresent(targetTile) then
    local topDest = targetTile:getTopUseThing()
    if topDest and targetTile:canShoot() then
      useWith(3148, topDest)
      return
    end
  end

  g_game.move(pushTarget, destPos)
  delay(1500)
end)
