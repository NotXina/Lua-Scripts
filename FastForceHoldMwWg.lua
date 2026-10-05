-- ============================================================================
-- FAST FORCE HOLD MW & WG (COM TIMER & PRE-CAST ZERO-DELAY)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local mwHotkey = "f3"
local wgHotkey = "f4"

local mwDuration = 20000  -- Duração da Magic Wall em ms (20s)
local wgDuration = 45000  -- Duração da Wild Growth em ms (45s padrão)
local preCastTime = 180   -- Milissegundos de antecipação para cobrir o ping

local mwId = 3180 -- ID da runa de Magic Wall
local wgId = 3156 -- ID da runa de Wild Growth

storage.mwPoses = storage.mwPoses or {}
storage.wgPoses = storage.wgPoses or {}

local wallTimers = {}
local lastCast = {}

-- IDs de Magic Wall e Wild Growth
local wallIds = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [9598] = true, [9599] = true,
  [10187] = true, [10188] = true, [10189] = true
}

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

-- Macro de Magic Wall com Timer e Pre-Cast
macro(10, "Force Hold Mw (20s)", function()
  if #storage.mwPoses == 0 then return end
  local pPos = pos()
  local t = now or g_clock.millis()
  
  for _, mPos in ipairs(storage.mwPoses) do
    if mPos.z == pPos.z and getDistanceBetween(pPos, mPos) <= 7 then
      local tile = g_map.getTile(mPos)
      if tile then
        local key = getKey(mPos)
        local wallPresent = hasWall(tile)
        
        if wallPresent then
          if not wallTimers[key] then
            wallTimers[key] = t + mwDuration
          end
          
          local remaining = math.max(0, (wallTimers[key] - t) / 1000)
          tile:setText(string.format("MW\n%.1fs", remaining))
          
          -- Pre-cast antes da wall sumir para zero gap
          if (wallTimers[key] - t) <= preCastTime then
            castWall(mwId, tile, key, mwDuration)
          end
        else
          tile:setText("MW\n0.0s")
          castWall(mwId, tile, key, mwDuration)
        end
      end
    end
  end
end)

-- Macro de Wild Growth com Timer e Pre-Cast
macro(10, "Force Hold Wg (45s)", function()
  if #storage.wgPoses == 0 then return end
  local pPos = pos()
  local t = now or g_clock.millis()
  
  for _, mPos in ipairs(storage.wgPoses) do
    if mPos.z == pPos.z and getDistanceBetween(pPos, mPos) <= 7 then
      local tile = g_map.getTile(mPos)
      if tile then
        local key = getKey(mPos)
        local wallPresent = hasWall(tile)
        
        if wallPresent then
          if not wallTimers[key] then
            wallTimers[key] = t + wgDuration
          end
          
          local remaining = math.max(0, (wallTimers[key] - t) / 1000)
          tile:setText(string.format("WG\n%.1fs", remaining))
          
          if (wallTimers[key] - t) <= preCastTime then
            castWall(wgId, tile, key, wgDuration)
          end
        else
          tile:setText("WG\n0.0s")
          castWall(wgId, tile, key, wgDuration)
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
  if keys == mwHotkey:lower() then
    togglePos(storage.mwPoses, "MW", mwId, mwDuration)
  elseif keys == wgHotkey:lower() then
    togglePos(storage.wgPoses, "WG", wgId, wgDuration)
  end
end)

addButton("", "Clean All Positions", function()
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
end)
