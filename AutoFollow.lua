-- ============================================================================
-- AUTO FOLLOW (PATHFINDING OTIMIZADO & MULTI-FLOOR)
-- Segue o líder subindo e descendo escadas, buracos, corda e levitate,
-- abrindo portas fechadas no caminho
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

-- Abre portas fechadas no caminho do lider: o autoWalk com
-- ignoreNonPathable para na frente da porta sem abri-la. Mesma lista de IDs
-- de portas do "Auto Open Doors" do vBot 4.8.
local doorIds = { 5007, 8265, 1629, 1632, 5129, 6252, 6249, 7715, 7712, 7714,
                  7719, 6256, 1669, 1672, 5125, 5115, 5124, 17701, 17710, 1642,
                  6260, 5107, 4912, 6251, 5291, 1683, 1696, 1692, 5006, 2179, 5116,
                  1632, 11705, 30772, 30774, 6248, 5735, 5732, 5120, 23873, 5736,
                  6264, 5122, 30049, 30042, 7727 }

-- Abre uma porta fechada adjacente na direcao do alvo (reta ou diagonal).
local function openDoorTowards(targetPos)
  local p = pos()
  if not p or not targetPos or p.z ~= targetPos.z then return false end

  local dx = targetPos.x - p.x
  local dy = targetPos.y - p.y
  if dx == 0 and dy == 0 then return false end

  local dirs = {}
  if dx ~= 0 then table.insert(dirs, {x = dx > 0 and 1 or -1, y = 0}) end
  if dy ~= 0 then table.insert(dirs, {x = 0, y = dy > 0 and 1 or -1}) end
  if dx ~= 0 and dy ~= 0 then
    table.insert(dirs, {x = dx > 0 and 1 or -1, y = dy > 0 and 1 or -1})
  end

  for _, d in ipairs(dirs) do
    local tile = g_map.getTile({x = p.x + d.x, y = p.y + d.y, z = p.z})
    if tile then
      local thing = tile:getTopUseThing()
      if thing and table.find(doorIds, thing:getId()) then
        g_game.use(thing)
        return true
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
      if openDoorTowards(leaderPos) then
        delay(300) -- espera a porta abrir antes de continuar
        return
      end
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
      if openDoorTowards(lpos) then
        delay(300) -- espera a porta abrir antes de continuar
        return
      end
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
