-- ============================================================================
-- FAST FORCE HOLD MW & WG (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.forceHoldSettings = storage.forceHoldSettings or {
  enabled = true,
  mwHotkey = "f3",
  wgHotkey = "f4",
  mwId = 3180,
  wgId = 3156,
  preCastTime = 180
}
local config = storage.forceHoldSettings

local mwDuration = 20000
local wgDuration = 45000

storage.mwPoses = storage.mwPoses or {}
storage.wgPoses = storage.wgPoses or {}

local wallTimers = {}
local lastCast = {}

local wallIds = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [9598] = true, [9599] = true,
  [10187] = true, [10188] = true, [10189] = true
}

if forceHoldWindow then forceHoldWindow:destroy() end

g_ui.loadUIFromString([[
ForceHoldWindow < MainWindow
  text: Force Hold Setup
  size: 220 250
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Hotkey MW / WG:
    margin-top: 5

  Panel
    height: 30
    margin-top: 3

    TextEdit
      id: mwKeyText
      anchors.left: parent.left
      anchors.top: parent.top
      width: 90
      text-align: center

    TextEdit
      id: wgKeyText
      anchors.right: parent.right
      anchors.top: parent.top
      width: 90
      text-align: center

  HorizontalSeparator
    margin-top: 5

  Label
    id: precastLabel
    text-align: center
    text: Pre-cast: 180ms
    margin-top: 3

  HorizontalScrollBar
    id: precastScroll
    minimum: 50
    maximum: 400
    step: 10
    margin-top: 3

  HorizontalSeparator
    margin-top: 8

  Button
    id: cleanBtn
    text: Clean Positions
    margin-top: 3
    height: 20

  Button
    id: closeButton
    text: Close
    font: cipsoftFont
    margin-top: 5
    margin-left: 155
    width: 45
    height: 21
]])

forceHoldWindow = UI.createWindow('ForceHoldWindow', g_ui.getRootWidget())
forceHoldWindow:hide()

local function fhfhChild(id)
  local w = forceHoldWindow:recursiveGetChildById(id)
  if not w then
    error("[ForceHold] widget nao encontrado na UI: " .. tostring(id))
  end
  return w
end

local fh_mwKeyText = fhfhChild('mwKeyText')
local fh_wgKeyText = fhfhChild('wgKeyText')
local fh_precastScroll = fhfhChild('precastScroll')
local fh_precastLabel = fhfhChild('precastLabel')
local fh_cleanBtn = fhfhChild('cleanBtn')
local fh_closeButton = fhfhChild('closeButton')


fh_mwKeyText:setText(config.mwHotkey or "f3")
fh_mwKeyText.onTextChange = function(w, text)
  config.mwHotkey = text
end

fh_wgKeyText:setText(config.wgHotkey or "f4")
fh_wgKeyText.onTextChange = function(w, text)
  config.wgHotkey = text
end

fh_precastScroll:setValue(config.preCastTime or 180)
fh_precastLabel:setText("Pre-cast: " .. (config.preCastTime or 180) .. "ms")
fh_precastScroll.onValueChange = function(w, v)
  config.preCastTime = v
  fh_precastLabel:setText("Pre-cast: " .. v .. "ms")
end

fh_cleanBtn.onClick = function()
  for _, p in ipairs(storage.mwPoses) do
    local tile = g_map.getTile(p)
    if tile then tile:setText("") end
  end
  for _, p in ipairs(storage.wgPoses) do
    local tile = g_map.getTile(p)
    if tile then tile:setText("") end
  end
  storage.mwPoses = {}
  storage.wgPoses = {}
  wallTimers = {}
  lastCast = {}
end

fh_closeButton.onClick = function()
  forceHoldWindow:hide()
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
    !text: tr('Force Hold MW/WG')

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
  forceHoldWindow:show()
  forceHoldWindow:raise()
  forceHoldWindow:focus()
end

local function getKey(pos)
  return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function hasWall(tile)
  if not tile then return false end
  local items = tile:getItems()
  if items then
    for i = 1, #items do
      local it = items[i]
      if it and wallIds[it:getId()] then
        return true
      end
    end
  end
  local top = tile:getTopThing()
  if top and top:isItem() and wallIds[top:getId()] then
    return true
  end
  return false
end

local function castWall(runeId, tile, posKey, duration)
  local t = now or g_clock.millis()
  if (lastCast[posKey] or 0) + 400 > t then return end
  
  local target = tile:getTopUseThing() or tile:getGround()
  if target then
    useWith(runeId, target)
    lastCast[posKey] = t
    wallTimers[posKey] = t + duration
  end
end

macro(10, function()
  if not config.enabled then return end
  if #storage.mwPoses == 0 and #storage.wgPoses == 0 then return end
  local pPos = pos()
  local t = now or g_clock.millis()
  local preCast = config.preCastTime or 180

  -- MW Loop
  for _, mPos in ipairs(storage.mwPoses) do
    if mPos.z == pPos.z and getDistanceBetween(pPos, mPos) <= 7 then
      local tile = g_map.getTile(mPos)
      if tile then
        local key = getKey(mPos)
        if hasWall(tile) then
          if not wallTimers[key] then wallTimers[key] = t + mwDuration end
          local remaining = math.max(0, (wallTimers[key] - t) / 1000)
          tile:setText(string.format("MW\n%.1fs", remaining))
          if (wallTimers[key] - t) <= preCast then
            castWall(config.mwId or 3180, tile, key, mwDuration)
          end
        else
          tile:setText("MW\n0.0s")
          castWall(config.mwId or 3180, tile, key, mwDuration)
        end
      end
    end
  end

  -- WG Loop
  for _, mPos in ipairs(storage.wgPoses) do
    if mPos.z == pPos.z and getDistanceBetween(pPos, mPos) <= 7 then
      local tile = g_map.getTile(mPos)
      if tile then
        local key = getKey(mPos)
        if hasWall(tile) then
          if not wallTimers[key] then wallTimers[key] = t + wgDuration end
          local remaining = math.max(0, (wallTimers[key] - t) / 1000)
          tile:setText(string.format("WG\n%.1fs", remaining))
          if (wallTimers[key] - t) <= preCast then
            castWall(config.wgId or 3156, tile, key, wgDuration)
          end
        else
          tile:setText("WG\n0.0s")
          castWall(config.wgId or 3156, tile, key, wgDuration)
        end
      end
    end
  end
end)

local function togglePos(tbl, label, runeId, duration)
  local tile = getTileUnderCursor()
  if not tile then return end
  
  local p = tile:getPosition()
  local key = getKey(p)
  local foundIndex = nil
  
  for i, storedPos in ipairs(tbl) do
    if storedPos.x == p.x and storedPos.y == p.y and storedPos.z == p.z then
      foundIndex = i
      break
    end
  end
  
  if foundIndex then
    tile:setText("")
    table.remove(tbl, foundIndex)
    wallTimers[key] = nil
  else
    table.insert(tbl, {x = p.x, y = p.y, z = p.z})
    tile:setText(label)
    
    local t = now or g_clock.millis()
    if not hasWall(tile) then
      castWall(runeId, tile, key, duration)
    else
      wallTimers[key] = t + duration
    end
  end
end

onKeyDown(function(keys)
  keys = keys:lower()
  if keys == (config.mwHotkey or "f3"):lower() then
    togglePos(storage.mwPoses, "MW", config.mwId or 3180, mwDuration)
  elseif keys == (config.wgHotkey or "f4"):lower() then
    togglePos(storage.wgPoses, "WG", config.wgId or 3156, wgDuration)
  end
end)
