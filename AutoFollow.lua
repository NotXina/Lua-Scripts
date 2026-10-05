-- ============================================================================
-- AUTO FOLLOW (PATHFINDING OTIMIZADO & MULTI-FLOOR)
-- Segue o líder subindo e descendo escadas, buracos, corda e levitate
-- ============================================================================

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
