-- ============================================================================
-- STATUS EXP WIDGET (COMPACTO, ARRASTÁVEL, SALVA POSIÇÃO & ZERO LAG)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

-- Destrói janela anterior para não duplicar na memória RAM
if statusExpWidget then
  statusExpWidget:destroy()
  statusExpWidget = nil
end

-- Recupera a última posição salva (ou usa x:20, y:100 por padrão)
storage.statusExpPos = storage.statusExpPos or { x = 20, y = 100 }

local ui = setupUI([[
Panel
  id: statusExpPanel
  width: 140
  height: 142
  background-color: #000000aa
  border: 1 #ffffff22
  draggable: true
  phantom: false

  Button
    id: resetButton
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 5
    margin-left: 6
    width: 85
    height: 18
    text: Reset Session
    font: verdana-11px-rounded

  Label
    id: sessionTimeLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    text: "Sessao: 00:00:00"

  Label
    id: expPerHourLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    color: #ffd700
    text: "Exp/h: 0"

  Label
    id: initialLevelLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    text: "Lvl Inicial: 0"

  Label
    id: levelsGainedLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    color: #98fb98
    text: "Lvl Ganhos: 0"

  Label
    id: levelsPerHourLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    text: "Lvl/h: 0.00"

  Label
    id: nextLevelLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    text-auto-resize: true
    color: #87ceeb
    text: "Prox Lvl: --:--:--"
]], g_ui.getRootWidget())

statusExpWidget = ui

-- Aplica a posição gravada no storage
ui:setPosition(storage.statusExpPos)

-- ============================================================================
-- SISTEMA DE ARRASTAR E GRAVAR A POSIÇÃO
-- ============================================================================
ui.onDragEnter = function(widget, mousePos)
  widget.dragOffset = {
    x = mousePos.x - widget:getX(),
    y = mousePos.y - widget:getY()
  }
  return true
end

ui.onDragMove = function(widget, mousePos, mouseMoved)
  local newPos = {
    x = mousePos.x - widget.dragOffset.x,
    y = mousePos.y - widget.dragOffset.y
  }
  widget:setPosition(newPos)
  storage.statusExpPos = newPos
  return true
end

-- ============================================================================
-- LÓGICA DE DADOS & CÁLCULOS
-- ============================================================================
local startTime = os.time()
local initialLevel = player:getLevel()
local totalExpGained = 0

local function formatTime(seconds)
  if not seconds or seconds <= 0 then return "--:--:--" end
  if seconds >= 86400 then
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    return string.format("%dd %02dh", days, hours)
  end
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = math.floor(seconds % 60)
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function formatNumberAbbreviated(number)
  if not number then return "0" end
  local suffixes = { "", "k", "M", "B", "T" }
  local suffixIndex = 1

  while number >= 1000 and suffixIndex < #suffixes do
    number = number / 1000
    suffixIndex = suffixIndex + 1
  end

  return string.format("%.2f%s", number, suffixes[suffixIndex])
end

local function getExpForNextLevel(lvl)
  return 50 * (lvl * lvl - 3 * lvl + 4)
end

local function resetSession()
  startTime = os.time()
  initialLevel = player:getLevel()
  totalExpGained = 0
  
  ui.sessionTimeLabel:setText("Sessao: 00:00:00")
  ui.expPerHourLabel:setText("Exp/h: 0")
  ui.initialLevelLabel:setText("Lvl Inicial: " .. initialLevel)
  ui.levelsGainedLabel:setText("Lvl Ganhos: 0")
  ui.levelsPerHourLabel:setText("Lvl/h: 0.00")
  ui.nextLevelLabel:setText("Prox Lvl: --:--:--")
end

ui.resetButton.onClick = function()
  resetSession()
end

onTextMessage(function(mode, text)
  if text:find("experience point") or text:find("experience") then
    local expGained = text:match("You gained ([%d%s%.,]+) experience")
    if expGained then
      local cleanStr = expGained:gsub("[^%d]", "")
      local num = tonumber(cleanStr)
      if num and num > 0 then
        totalExpGained = totalExpGained + num
      end
    end
  end
end)

macro(1000, function()
  if not ui or not ui:isVisible() then return end

  local elapsedTime = math.max(1, os.time() - startTime)
  local hours = elapsedTime / 3600

  local expPerHour = (totalExpGained / elapsedTime) * 3600
  local currentLevel = player:getLevel()
  local levelsGained = math.max(0, currentLevel - initialLevel)
  local levelsPerHour = levelsGained / hours

  local nextLevelStr = "--:--:--"
  if expPerHour > 0 then
    local lvlPercent = player:getLevelPercent() or 0
    local percentRemaining = math.max(1, 100 - lvlPercent) / 100
    
    local totalLvlExp = getExpForNextLevel(currentLevel)
    local expRemaining = totalLvlExp * percentRemaining
    
    local expPerSec = expPerHour / 3600
    local secondsLeft = expRemaining / expPerSec

    nextLevelStr = formatTime(secondsLeft)
  end

  ui.sessionTimeLabel:setText("Sessao: " .. formatTime(elapsedTime))
  ui.expPerHourLabel:setText("Exp/h: " .. formatNumberAbbreviated(expPerHour))
  ui.initialLevelLabel:setText("Lvl Inicial: " .. initialLevel)
  ui.levelsGainedLabel:setText("Lvl Ganhos: " .. levelsGained)
  ui.levelsPerHourLabel:setText(string.format("Lvl/h: %.2f", levelsPerHour))
  ui.nextLevelLabel:setText("Prox Lvl: " .. nextLevelStr)
end)
