-- ============================================================================
--                        WARPW PVP PACK (OTIMIZADO)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local tab = addTab("WarPw")
setDefaultTab("WarPw")

-- ============================================================================
-- 1. CONFIGURAÇÕES & SAFE SD / UE
-- ============================================================================
storage.safeSdMasFrigo = storage.safeSdMasFrigo or {}
local safeSettings = storage.safeSdMasFrigo
if safeSettings.safeRange == nil then safeSettings.safeRange = 8 end

addLabel("", "Magia no modo seguro (UE):"):setColor("orange")
addTextEdit("TxtEditSpell", safeSettings.Spell or "exevo gran mas frigo", function(widget, text)
  safeSettings.Spell = text
end)

-- A única trava da UE é encontrar, no mesmo andar e dentro do raio,
-- outro jogador cujo shield seja diferente do shield do personagem local.
-- Não há bloqueio separado por guild, party, amizade ou distância do alvo.
local function hasDifferentShieldNearby(range)
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then return false end

  local myShield = localPlayer:getShield() or 0
  local pPos = localPlayer:getPosition()
  for _, spec in ipairs(getSpectators(pPos.z, false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      local specPos = spec:getPosition()
      if specPos.z == pPos.z
        and getDistanceBetween(pPos, specPos) <= range
        and (spec:getShield() or 0) ~= myShield then
        return true
      end
    end
  end
  return false
end

macro(1000, "Safe SD/UE", function()
  local target = g_game.getAttackingCreature()
  if not target then return end

  -- Continua usando UE; só troca para SD se encontrar um shield diferente.
  if not hasDifferentShieldNearby(safeSettings.safeRange or 8) then
    local spell = safeSettings.Spell
    if spell and spell:match("%S") then
      say(spell)
    end
  else
    -- Shield diferente por perto: não solta UE e usa SD no alvo.
    useWith(3155, target)
  end
end)

-- Esconder Sprites de Efeitos/Magias
local sprh = macro(100, "Esconde Sprite Magias", function() end)
onAddThing(function(tile, thing)
  if sprh.isOff() then return end
  if thing and thing:isEffect() then
    thing:hide()
  end
end)

addSeparator()

-- ============================================================================
-- 2. AUTO TRAP EM SI (MAGIC WALL 8 SQMs)
-- ============================================================================
local MW_RUNE_ID = 3180
local MW_ITEM_IDS = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [10188] = true, [10189] = true
}

local wallOffsets = {
  {-1, -1}, { 0, -1}, { 1, -1},
  {-1,  0},           { 1,  0},
  {-1,  1}, { 0,  1}, { 1,  1}
}

local function hasWall(tile)
  if not tile then return true end
  for _, item in ipairs(tile:getItems() or {}) do
    if MW_ITEM_IDS[item:getId()] then return true end
  end
  return false
end

local function throwMw(offsetX, offsetY)
  local player = g_game.getLocalPlayer()
  if not player then return false end

  local pPos = player:getPosition()
  local targetPos = {x = pPos.x + offsetX, y = pPos.y + offsetY, z = pPos.z}
  local tile = g_map.getTile(targetPos)

  if tile and not hasWall(tile) and tile:isWalkable(false) then
    local ground = tile:getTopUseThing() or tile:getGround()
    if ground then
      useWith(MW_RUNE_ID, ground)
      return true
    end
  end
  return false
end

macro(50, "Trapa em si MW", "NumPad5", function()
  for _, off in ipairs(wallOffsets) do
    if throwMw(off[1], off[2]) then
      delay(200)
      return
    end
  end
end)

addSeparator()
addLabel("", "Suporte & Cura"):setColor("red")
addSeparator()

-- ============================================================================
-- 3. CURA DE TIME (UH & SIO)
-- ============================================================================
-- UH no Time (Foca no amigo com menor HP)
macro(500, "UH NO TIME", function()
  if hppercent() <= 90 then return end

  local lowestFriend = nil
  local lowestHp = 91

  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName()) then
        local hp = spec:getHealthPercent()
        if hp < lowestHp and hp > 0 then
          lowestHp = hp
          lowestFriend = spec
        end
      end
    end
  end

  if lowestFriend then
    useWith(3160, lowestFriend)
    delay(400)
  end
end)

-- Sio Friend com Slider
local sioPanelName = "SioFriendConfig"
storage[sioPanelName] = storage[sioPanelName] or { enabled = true, hpAmigos = 90 }

local sioUi = setupUI([[
Panel
  height: 45

  BotLabel
    id: hpLabel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  HorizontalScrollBar
    id: hpSlider
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: hpLabel.bottom
    minimum: 1
    maximum: 100
    step: 1
]], parent)

local function updateSioLabel()
  sioUi.hpLabel:setText("Curar abaixo de: " .. storage[sioPanelName].hpAmigos .. "% HP")
end

sioUi.hpSlider.onValueChange = function(scroll, value)
  storage[sioPanelName].hpAmigos = value
  updateSioLabel()
end
sioUi.hpSlider:setValue(storage[sioPanelName].hpAmigos)
updateSioLabel()

macro(400, "Sio Friend", function()
  if not storage[sioPanelName].enabled then return end
  local p = g_game.getLocalPlayer()
  if not p or (p:getHealth() / p:getMaxHealth()) <= 0.5 then return end

  for _, friend in ipairs(getSpectators(posz(), false) or {}) do
    if friend:isPlayer() and not friend:isLocalPlayer() then
      if friend:getShield() >= 3 or friend:getEmblem() == 1 or isFriend(friend:getName()) then
        if friend:getHealthPercent() <= storage[sioPanelName].hpAmigos and friend:getHealthPercent() > 0 then
          say('Exura Sio "' .. friend:getName())
          delay(400)
          return
        end
      end
    end
  end
end)

addSeparator()
addLabel("", "Ataque & Combo"):setColor("green")
addSeparator()

-- ============================================================================
-- 4. AUTO ATTACK PLAYERS (FOCA MENOR HP)
-- ============================================================================
macro(100, "Attack Players", "Delete", function()
  local lowestHp = 101
  local closestDist = math.huge
  local targetPlayer = nil
  local myName = name():lower()
  local pPos = pos()

  for _, creature in ipairs(getSpectators(pPos.z, false) or {}) do
    if creature:isPlayer() then
      local cName = creature:getName()
      local lowerName = cName:lower()
      local shield = creature:getShield() or 0
      local emblem = creature:getEmblem() or 0
      local hp = creature:getHealthPercent()
      local dist = getDistanceBetween(pPos, creature:getPosition())

      local validTarget = lowerName ~= myName
        and hp and hp > 0
        and not isFriend(cName)
        and shield < 3
        and emblem ~= 1

      if validTarget then
        if hp < lowestHp or (hp == lowestHp and dist < closestDist) then
          lowestHp = hp
          closestDist = dist
          targetPlayer = creature
        end
      end
    end
  end

  if targetPlayer then
    local current = g_game.getAttackingCreature()
    if not g_game.isAttacking() or current ~= targetPlayer then
      g_game.attack(targetPlayer)
    end
  end
end)

-- ============================================================================
-- 5. COMBO ATTACK COM LÍDERES
-- ============================================================================
storage.ComboAttack = storage.ComboAttack or {}
local comboSettings = storage.ComboAttack

-- Os nomes só eram gravados no storage quando o campo era editado. Sem isso,
-- comboSettings.LeaderName era nil e o onMissle quebrava em LeaderName:lower().
comboSettings.LeaderName = comboSettings.LeaderName or "Leader1"
comboSettings.LeaderName2 = comboSettings.LeaderName2 or "Leader2"
comboSettings.LeaderName3 = comboSettings.LeaderName3 or "Leader3"

addLabel("", "Líder 1:")
addTextEdit("TxtEditLeader1", comboSettings.LeaderName or "Leader1", function(widget, text)
  comboSettings.LeaderName = text
end)

addLabel("", "Líder 2:")
addTextEdit("TxtEditLeader2", comboSettings.LeaderName2 or "Leader2", function(widget, text)
  comboSettings.LeaderName2 = text
end)

addLabel("", "Líder 3:")
addTextEdit("TxtEditLeader3", comboSettings.LeaderName3 or "Leader3", function(widget, text)
  comboSettings.LeaderName3 = text
end)

local comboMacro = macro(10000, "Combo Attack", function() end)

onMissle(function(missle)
  if comboMacro.isOff() then return end
  local src = missle:getSource()
  if src.z ~= posz() then return end

  local from = g_map.getTile(src)
  local to = g_map.getTile(missle:getDestination())
  if not from or not to then return end

  local fromCreatures = from:getCreatures()
  local toCreatures = to:getCreatures()
  if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end

  local shooter = fromCreatures[1]
  local target = toCreatures[1]

  local leaders = {}
  for _, leaderName in ipairs({comboSettings.LeaderName, comboSettings.LeaderName2, comboSettings.LeaderName3}) do
    if type(leaderName) == "string" and leaderName:match("%S") then
      table.insert(leaders, leaderName:lower())
    end
  end
  if #leaders == 0 then return end

  if table.find(leaders, shooter:getName():lower()) then
    local current = g_game.getAttackingCreature()
    if (not current or current ~= target) and not isFriend(target:getName()) then
      g_game.attack(target)
    end
  end
end)

addSeparator()
addLabel("", "Defesa de SQM (Flores)"):setColor("pink")
addSeparator()

-- ============================================================================
-- 6. PROTEÇÃO DE SQM & FLORES (ANTI-PUSH COM FLORES)
-- ============================================================================
local flowerIds = {2981, 2983, 2984, 2985}
local flowerDirs = {
  {x=0, y=-1}, {x=1, y=0}, {x=0, y=1}, {x=-1, y=0},
  {x=1, y=-1}, {x=1, y=1}, {x=-1, y=1}, {x=-1, y=-1}
}

local protectPos = nil
local protectActive = false

local function hasFlower(tile)
  if not tile then return false end
  local item = tile:getTopThing()
  return item and table.find(flowerIds, item:getId())
end

local function getFlowerItem()
  for _, id in ipairs(flowerIds) do
    local item = findItem(id)
    if item then return item end
  end
  return nil
end

local function plantAround(centerPos)
  if not centerPos then return end
  for _, off in ipairs(flowerDirs) do
    local p = {x = centerPos.x + off.x, y = centerPos.y + off.y, z = centerPos.z}
    local tile = g_map.getTile(p)
    if tile and not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, p, 1)
        delay(100)
        return
      end
    end
  end
end

-- Hotkey F7: Marca/Desmarca SQM para proteger
singlehotkey("F7", "Proteger Sqm", function()
  local tile = getTileUnderCursor()
  if not tile then return end
  local p = tile:getPosition()

  if protectPos and p.x == protectPos.x and p.y == protectPos.y and p.z == protectPos.z then
    tile:setText("")
    protectPos = nil
    protectActive = false
    return
  end

  if protectPos then
    local oldTile = g_map.getTile(protectPos)
    if oldTile then oldTile:setText("") end
  end

  tile:setText("Proteger", "green")
  protectPos = p
  protectActive = true
  plantAround(protectPos)
end)

onKeyDown(function(keys)
  if keys:upper() == "ESC" and protectPos then
    local tile = g_map.getTile(protectPos)
    if tile then tile:setText("") end
    protectPos = nil
    protectActive = false
  end
end)

onRemoveThing(function(tile, thing)
  if not protectActive or not protectPos then return end
  local p = tile:getPosition()
  if p.z ~= protectPos.z then return end

  local dx, dy = math.abs(p.x - protectPos.x), math.abs(p.y - protectPos.y)
  if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0) then
    if not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, p, 1)
      end
    end
  end
end)

-- Macro de Flores ao redor do próprio char
macro(250, "Flowers Xina", function()
  local pPos = pos()
  for _, off in ipairs(flowerDirs) do
    local targetPos = {x = pPos.x + off.x, y = pPos.y + off.y, z = pPos.z}
    local tile = g_map.getTile(targetPos)
    if tile and not hasFlower(tile) then
      local flower = getFlowerItem()
      if flower then
        g_game.move(flower, targetPos, 1)
        delay(150)
        return
      end
    end
  end
end)

-- ============================================================================
-- 7. COORDENADAS NO MINIMAP
-- ============================================================================
if modules.game_minimap and modules.game_minimap.minimapWidget then
  local minimap = modules.game_minimap.minimapWidget
  local coordLabel = minimap.coords or g_ui.loadUIFromString([[
Label
  id: coords
  color: white
  font: verdana-11px-rounded
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  text-align: center
  margin-right: 3
  margin-left: 3
  text: ""
]], minimap)

  onPlayerPositionChange(function(newPos, oldPos)
    if coordLabel and newPos then
      coordLabel:setText(newPos.x .. ', ' .. newPos.y .. ', ' .. newPos.z)
    end
  end)
end
