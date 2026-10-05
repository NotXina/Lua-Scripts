-- ============================================================================
--                       XINA CORE PACK  -  OTCv8 3.2 / vBot 4.8
-- ----------------------------------------------------------------------------
--  Pack unico e organizado com os modulos avulsos deste repositorio.
--  Tudo fica dentro da aba "Xina Core", dividido por secoes:
--
--    1. COMBATE          -> Attack Players, Auto SD, Fast Paralyze Cure,
--                           Auto Destroy Field
--    2. TRAP / MW / WG   -> MW Self Step, Trap em si (MW), Trap WG Diagonais,
--                           Machete no WG, Timer visual de MW
--    3. CURA & SUPORTE   -> UH No Time, Renew Utamo Vita
--    4. EQUIPAMENTOS     -> Smart Energy Ring
--    5. MOVIMENTACAO     -> Auto Chase, Auto Mount, Auto Invis, Bug Map Dash,
--                           Anti-Push (moedas), Flores ao redor
--    6. HUD & INTERFACE  -> Target HUD, Coordenadas no minimapa,
--                           Icones CaveBot / TargetBot
--
--  Todos os modulos comecam DESLIGADOS. Ligue pelo painel do bot ou pelos
--  icones na tela. Ajuste tudo na tabela CONFIG logo abaixo.
--
--  AVISO: nao carregue este pack junto com os scripts avulsos equivalentes
--  (MWSelfStep.lua, AutoChase.lua, etc) para nao duplicar macros e hotkeys.
-- ============================================================================

-- ============================================================================
-- CONFIGURACOES GERAIS
-- ============================================================================
local CONFIG = {
  -- Runas e itens
  mwId            = 3180,   -- Magic Wall      (2293 em 7.4/8.0)
  wgId            = 3156,   -- Wild Growth
  sdId            = 3155,   -- Sudden Death
  uhId            = 3160,   -- Ultimate Healing Rune
  destroyFieldId  = 3148,   -- Destroy Field
  macheteId       = 3308,   -- Machete / Tramontina
  energyRingId    = 3051,   -- Energy Ring
  trashId         = 3031,   -- Anti-Push: 3031 = Gold | 3035 = Platinum
  flowerIds       = {2981, 2983, 2984, 2985},

  -- Combate
  sdMaxDistance   = 7,      -- Distancia maxima para soltar SD no alvo
  wgMaxDistance   = 6,      -- Distancia maxima para trapar WG no alvo
  cureSpell       = "exura",-- Magia usada para curar paralyze

  -- Cura
  uhMyMinHp       = 90,     -- So cura amigo se o SEU hp estiver acima disso
  utamoDuration   = 180,    -- Duracao do utamo vita (segundos)
  utamoRenewEarly = 20,     -- Renova X segundos antes de acabar

  -- Energy Ring
  eRingEquipHp    = 40,     -- Equipa abaixo de X% de hp
  eRingUnequipHp  = 70,     -- Desequipa acima de X% de hp

  -- Diversos
  mwDuration      = 20000,  -- Duracao da MW em ms (timer visual)
  dashDistance    = 5,      -- SQMs por passo do Bug Map Dash

  -- Hotkeys
  hkAttackPlayers = "Delete",
  hkTrapSelfMw    = "NumPad5",
  hkMachete       = "F1",
  hkDash          = "NumPad0",
}

-- ============================================================================
-- INFRAESTRUTURA DA ABA
-- ============================================================================
local TAB = "Xina Core"
addTab(TAB)
setDefaultTab(TAB)

local function section(title)
  UI.Label("== " .. title .. " ==")
  UI.Separator()
end

-- Helpers compartilhados -----------------------------------------------------
local WALL_IDS = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [10188] = true, [10189] = true
}

local AROUND = {
  {-1, -1}, { 0, -1}, { 1, -1},
  {-1,  0},           { 1,  0},
  {-1,  1}, { 0,  1}, { 1,  1}
}

local DIAGONALS = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}

local function tileAt(centerPos, offX, offY)
  if not centerPos then return nil end
  return g_map.getTile({x = centerPos.x + offX, y = centerPos.y + offY, z = centerPos.z})
end

local function hasWall(tile)
  if not tile then return true end
  for _, item in ipairs(tile:getItems() or {}) do
    if WALL_IDS[item:getId()] then return true end
  end
  return false
end

local function useRuneOnTile(runeId, tile)
  if not tile then return false end
  local target = tile:getTopUseThing() or tile:getGround()
  if not target then return false end
  useWith(runeId, target)
  return true
end

local function millis()
  return now or g_clock.millis()
end

-- ============================================================================
-- 1. COMBATE
-- ============================================================================
section("Combate")

-- 1.1 Attack Players: foca o inimigo com menor HP (empate = mais proximo) ----
macro(100, "Attack Players (menor HP)", CONFIG.hkAttackPlayers, function()
  local lowestHp, closestDist, targetPlayer = 101, math.huge, nil
  local myName, pPos = name():lower(), pos()

  for _, creature in ipairs(getSpectators(pPos.z, false) or {}) do
    if creature:isPlayer() then
      local cName = creature:getName()
      local hp = creature:getHealthPercent()
      local dist = getDistanceBetween(pPos, creature:getPosition())
      local valid = cName:lower() ~= myName
        and hp and hp > 0
        and not isFriend(cName)
        and (creature:getShield() or 0) < 3
        and (creature:getEmblem() or 0) ~= 1

      if valid and (hp < lowestHp or (hp == lowestHp and dist < closestDist)) then
        lowestHp, closestDist, targetPlayer = hp, dist, creature
      end
    end
  end

  if targetPlayer then
    if not g_game.isAttacking() or g_game.getAttackingCreature() ~= targetPlayer then
      g_game.attack(targetPlayer)
    end
  end
end)

-- 1.2 Auto SD no alvo -------------------------------------------------------
macro(100, "Auto SD no alvo", function()
  local target = g_game.getAttackingCreature()
  if not target then return end
  local tPos = target:getPosition()
  if tPos.z == posz() and getDistanceBetween(pos(), tPos) <= CONFIG.sdMaxDistance then
    useWith(CONFIG.sdId, target)
    delay(200)
  end
end)

-- 1.3 Fast Paralyze Cure (zero delay) ---------------------------------------
macro(20, "Fast Paralyze Cure", function()
  if isParalyzed() then
    say(CONFIG.cureSpell)
    delay(100)
  end
end)

-- 1.4 Auto Destroy Field no pe ----------------------------------------------
local DANGEROUS_FIELDS = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire
  [2123] = true, [2124] = true, [2125] = true, -- Poison
  [2126] = true, [2127] = true                 -- Energy
}

macro(150, "Auto Destroy Field", function()
  local tile = g_map.getTile(pos())
  if not tile then return end
  for _, item in ipairs(tile:getItems() or {}) do
    if DANGEROUS_FIELDS[item:getId()] then
      useWith(CONFIG.destroyFieldId, item)
      delay(300)
      return
    end
  end
end)

-- ============================================================================
-- 2. TRAP / MAGIC WALL / WILD GROWTH
-- ============================================================================
section("Trap / MW / WG")

-- 2.1 MW Self Step: MW no SQM que voce acabou de deixar ---------------------
local selfStep = macro(1000, "MW Self Step", function() end)

onPlayerPositionChange(function(newPos, oldPos)
  if not selfStep.isOn() then return end
  if oldPos and oldPos.z == posz() then
    local tile = g_map.getTile(oldPos)
    if tile and tile:isWalkable() then
      useRuneOnTile(CONFIG.mwId, tile)
    end
  end
end)

-- 2.2 Trapa em si: MW nos 8 SQMs ao redor -----------------------------------
macro(50, "Trapa em si (MW)", CONFIG.hkTrapSelfMw, function()
  local pPos = pos()
  for _, off in ipairs(AROUND) do
    local tile = tileAt(pPos, off[1], off[2])
    if tile and not hasWall(tile) and tile:isWalkable(false) then
      if useRuneOnTile(CONFIG.mwId, tile) then
        delay(200)
        return
      end
    end
  end
end)

-- 2.3 Trap WG nas diagonais do alvo -----------------------------------------
macro(100, "Trap WG diagonais", function()
  local target = g_game.getAttackingCreature()
  if not target then return end
  local tPos = target:getPosition()
  if tPos.z ~= posz() or getDistanceBetween(pos(), tPos) > CONFIG.wgMaxDistance then return end

  for _, off in ipairs(DIAGONALS) do
    local tile = tileAt(tPos, off[1], off[2])
    if tile and tile:isWalkable() then
      if useRuneOnTile(CONFIG.wgId, tile) then
        delay(150)
        return
      end
    end
  end
end)

-- 2.4 Machete / Tramontina no Wild Growth -----------------------------------
addIcon("XC_Machete", {item = {id = CONFIG.macheteId, count = 1}, text = "Machete", hotkey = CONFIG.hkMachete},
  macro(200, function()
    local pPos = pos()
    for _, off in ipairs(AROUND) do
      local tile = tileAt(pPos, off[1], off[2])
      if tile then
        local topThing = tile:getTopThing()
        if topThing and topThing:getId() == 2130 then
          useWith(CONFIG.macheteId, topThing)
          return
        end
      end
    end
  end))

-- 2.5 Timer visual das Magic Walls na tela ----------------------------------
local wallTimers = {}

macro(50, "Timer visual de MW", function()
  local t = millis()
  for _, tile in ipairs(g_map.getTiles(posz()) or {}) do
    local tPos = tile:getPosition()
    local key = tPos.x .. "," .. tPos.y .. "," .. tPos.z
    local found = false

    for _, it in ipairs(tile:getItems() or {}) do
      if WALL_IDS[it:getId()] then found = true break end
    end

    if found then
      wallTimers[key] = wallTimers[key] or (t + CONFIG.mwDuration)
      tile:setText(string.format("%.1fs", math.max(0, (wallTimers[key] - t) / 1000)))
    elseif wallTimers[key] then
      wallTimers[key] = nil
      tile:setText("")
    end
  end
end)

-- ============================================================================
-- 3. CURA & SUPORTE
-- ============================================================================
section("Cura & Suporte")

-- 3.1 UH No Time: UH no amigo com menor HP ----------------------------------
macro(500, "UH No Time (amigo)", function()
  if hppercent() <= CONFIG.uhMyMinHp then return end

  local lowestFriend, lowestHp = nil, CONFIG.uhMyMinHp + 1
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName()) then
        local hp = spec:getHealthPercent()
        if hp > 0 and hp < lowestHp then
          lowestHp, lowestFriend = hp, spec
        end
      end
    end
  end

  if lowestFriend then
    useWith(CONFIG.uhId, lowestFriend)
    delay(400)
  end
end)

-- 3.2 Renovacao inteligente do Utamo Vita -----------------------------------
local nextUtamo = 0
addIcon("XC_Utamo", {item = {id = 3548, count = 1}, text = "Utamo"}, macro(500, function()
  local t = millis()
  if not hasManaShield() or t > nextUtamo then
    say("utamo vita")
    nextUtamo = t + ((CONFIG.utamoDuration - CONFIG.utamoRenewEarly) * 1000)
    delay(500)
  end
end))

-- ============================================================================
-- 4. EQUIPAMENTOS
-- ============================================================================
section("Equipamentos")

-- 4.1 Smart Energy Ring ------------------------------------------------------
macro(50, "Smart Energy Ring", function()
  local hp = hppercent()
  local ring = getFinger()

  if hp <= CONFIG.eRingEquipHp then
    if not ring or ring:getId() ~= CONFIG.energyRingId then
      g_game.equipItemId(CONFIG.energyRingId)
    end
  elseif hp >= CONFIG.eRingUnequipHp then
    if ring and ring:getId() == CONFIG.energyRingId then
      local bp = getBack()
      if bp then g_game.move(ring, bp:getPosition(), 1) end
    end
  end
end)

-- ============================================================================
-- 5. MOVIMENTACAO & PUSH
-- ============================================================================
section("Movimentacao & Push")

-- 5.1 Auto Chase (sem spam de pacotes) --------------------------------------
addIcon("XC_Chase", {item = {id = 3555, count = 1}, text = "Chase"}, macro(500, function()
  if g_game.getChaseMode() ~= 1 then
    g_game.setChaseMode(1)
  end
end))

-- 5.2 Auto Mount ao sair do PZ ----------------------------------------------
addIcon("XC_Mount", {item = {id = 390, count = 1}, text = "Mount"}, macro(3000, function()
  if isInPz() then return end
  local p = g_game.getLocalPlayer()
  if p and not p:isMounted() then p:mount() end
end))

-- 5.3 Auto Invis (utana vid) -------------------------------------------------
addIcon("XC_Invis", {item = {id = 2202, count = 1}, text = "Invis"}, macro(5000, function()
  local p = g_game.getLocalPlayer()
  if p and not p:isInvisible() and not isInPz() then
    say("utana vid")
  end
end))

-- 5.4 Bug Map Dash (W A S D / setas) ----------------------------------------
local function dashTo(offX, offY)
  local tile = tileAt(pos(), offX, offY)
  if tile then
    local top = tile:getTopUseThing()
    if top then g_game.use(top) end
  end
end

local bugMap = macro(25, function()
  local kb = g_keyboard
  local d = CONFIG.dashDistance
  if kb.isKeyPressed('Up') or kb.isKeyPressed('w') then
    dashTo(0, -d)
  elseif kb.isKeyPressed('Right') or kb.isKeyPressed('d') then
    dashTo(d, 0)
  elseif kb.isKeyPressed('Down') or kb.isKeyPressed('s') then
    dashTo(0, d)
  elseif kb.isKeyPressed('Left') or kb.isKeyPressed('a') then
    dashTo(-d, 0)
  end
end)
bugMap.setOff()

addIcon("XC_Dash", {item = 3368, text = "DASH", hotkey = CONFIG.hkDash}, function(icon, isOn)
  modules.game_console.consoleTextEdit:setVisible(not isOn)
  bugMap.setOn(isOn)
end)

-- 5.5 Anti-Push com moedas ---------------------------------------------------
macro(100, "Anti-Push (moedas)", function()
  local pPos = pos()
  local tile = g_map.getTile(pPos)
  if not tile then return end

  local top = tile:getTopThing()
  if not top or top:getId() ~= CONFIG.trashId then
    local item = findItem(CONFIG.trashId)
    if item then g_game.move(item, pPos, 1) end
  end
end)

-- 5.6 Flores nos 8 SQMs ao redor --------------------------------------------
local function hasFlower(tile)
  if not tile then return false end
  local item = tile:getTopThing()
  return item and table.find(CONFIG.flowerIds, item:getId())
end

local function findFlower()
  for _, id in ipairs(CONFIG.flowerIds) do
    local item = findItem(id)
    if item then return item end
  end
end

macro(250, "Flores ao redor", function()
  local pPos = pos()
  for _, off in ipairs(AROUND) do
    local targetPos = {x = pPos.x + off[1], y = pPos.y + off[2], z = pPos.z}
    local tile = g_map.getTile(targetPos)
    if tile and not hasFlower(tile) then
      local flower = findFlower()
      if flower then
        g_game.move(flower, targetPos, 1)
        delay(150)
        return
      end
    end
  end
end)

-- ============================================================================
-- 6. HUD & INTERFACE
-- ============================================================================
section("HUD & Interface")

-- 6.1 Target HUD (nick / hp / distancia) -------------------------------------
if xcTargetHud then
  xcTargetHud:destroy()
  xcTargetHud = nil
end

xcTargetHud = setupUI([[
Label
  id: xcTargetHud
  font: verdana-11px-rounded
  color: red
  text-auto-resize: true
  phantom: true
  text: ""
]], g_ui.getRootWidget())
xcTargetHud:setPosition({x = 450, y = 30})
xcTargetHud:hide()

macro(50, "Target HUD", function()
  local target = g_game.getAttackingCreature()
  if target and target:isPlayer() then
    xcTargetHud:setText(string.format("ALVO: %s | HP: %d%% | DIST: %d",
      target:getName(), target:getHealthPercent(),
      getDistanceBetween(pos(), target:getPosition())))
    xcTargetHud:show()
  else
    xcTargetHud:hide()
  end
end)

-- 6.2 Coordenadas no minimapa ------------------------------------------------
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

  onPlayerPositionChange(function(newPos)
    if coordLabel and newPos then
      coordLabel:setText(newPos.x .. ', ' .. newPos.y .. ', ' .. newPos.z)
    end
  end)
end

-- 6.3 Icones CaveBot / TargetBot com indicador ON-OFF ------------------------
if CaveBot and TargetBot then
  local cIcon = addIcon("XC_Cave", {text = "Cave\nBot", switchable = false, moveable = true}, function()
    if CaveBot.isOff() then CaveBot.setOn() else CaveBot.setOff() end
  end)
  cIcon:setSize({height = 30, width = 50})
  cIcon.text:setFont('verdana-11px-rounded')

  local tIcon = addIcon("XC_Target", {text = "Target\nBot", switchable = false, moveable = true}, function()
    if TargetBot.isOff() then TargetBot.setOn() else TargetBot.setOff() end
  end)
  tIcon:setSize({height = 30, width = 50})
  tIcon.text:setFont('verdana-11px-rounded')

  macro(300, function()
    if CaveBot.isOn() then
      cIcon.text:setColoredText({"CaveBot\n", "white", "ON", "green"})
    else
      cIcon.text:setColoredText({"CaveBot\n", "white", "OFF", "red"})
    end
    if TargetBot.isOn() then
      tIcon.text:setColoredText({"Target\n", "white", "ON", "green"})
    else
      tIcon.text:setColoredText({"Target\n", "white", "OFF", "red"})
    end
  end)
end

setDefaultTab("Main")
