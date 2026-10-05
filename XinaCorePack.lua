-- ============================================================================
--                       XINA CORE PACK  -  OTCv8 3.2 / vBot 4.8
-- ----------------------------------------------------------------------------
--  Pack unico e organizado com os modulos avulsos deste repositorio.
--  Tudo fica dentro da aba "Xina Core", dividido por secoes:
--
--    1. COMBATE          -> Attack Players, Auto SD, Safe SD/UE, Combo Attack,
--                           Fast Paralyze Cure, Destroy Field, Tela Limpa
--    2. TRAP / MW        -> MW Self Step, Trapa em si, Trapa Alvo WG/MW,
--                           Force Hold MW/WG, MW Enemy Step, Machete no WG
--    3. CURA & SUPORTE   -> UH No Time, Renew Utamo Vita, Pot Friend, Sio Friend
--    4. EQUIPAMENTOS     -> Smart Energy Ring, Energy Ring, Ring Invertido
--    5. MOVIMENTACAO     -> Chase, Mount, Invis, Dash, Anti-Push, Flores,
--
--    6. UTILITARIOS      -> Pick-Up Items, Stamina Items, Vende Tudo
--    7. HUD & INTERFACE  -> Target HUD, Coordenadas no minimapa,
--                           Icones CaveBot / TargetBot, SDMAX / PARAMAX / AVAMAX
--
--  Ficaram de fora somente Trap WG diagonais e o Timer visual de MW
--  (gastam runa a toa / podem gerar lag). Continuam como scripts avulsos.
--
--  Todos os modulos comecam DESLIGADOS. Ligue pelo painel do bot ou pelos
--  icones na tela. Os modulos configuraveis possuem um botao Setup proprio.
--
--  AVISO: nao carregue este pack junto com os scripts avulsos equivalentes
--  (MWSelfStep.lua, PotFriend.lua, AutoSioParty.lua, etc)
--  para nao duplicar macros, callbacks, swappers e hotkeys.
--
--  EXCECAO: o IconesDashPack.lua PODE ficar ligado junto com este pack.
--  Machete, icones de CaveBot/TargetBot, Dash, Invis, Mount, Utamo, Chase e
--  icones Max existem nos dois arquivos; eles usam "claimSharedIcon" (ver abaixo) para
--  combinar entre si e garantir que só UM dos dois crie aquele icone/macro/
--  hotkey, evitando duplicidade e o dobro de timers rodando (= menos lag).
-- ============================================================================

-- ============================================================================
-- TRAVA COMPARTILHADA COM O IconesDashPack.lua
-- ============================================================================
xinaSharedIcons = xinaSharedIcons or {}

-- O g_clock não é exposto por todas as versões do OTCv8/vBot. Usa o relógio
-- do vBot quando disponível e mantém fallbacks compatíveis para o carregamento.
local function millis()
  if type(now) == "number" then return now end
  if g_clock and type(g_clock.millis) == "function" then return g_clock.millis() end
  return os.time() * 1000
end

-- "Reivindica" um modulo compartilhado com o IconesDashPack.lua. Retorna
-- true só para quem chamar primeiro; expira sozinha depois de alguns
-- segundos para não "perder" o icone caso os scripts sejam recarregados em
-- momentos diferentes (ex.: editar e salvar só um dos dois arquivos no bot).
local function claimSharedIcon(key)
  local timestamp = millis()
  local claimedAt = xinaSharedIcons[key]
  if claimedAt and (timestamp - claimedAt) < 3000 then
    return false
  end
  xinaSharedIcons[key] = timestamp
  return true
end

-- ============================================================================
-- CONFIGURACOES GERAIS
-- ============================================================================
local CONFIG = {
  -- Runas e itens
  mwId            = 3180,   -- Magic Wall      (2293 em 7.4/8.0)
  sdId            = 3155,   -- Sudden Death    (2268 em versoes antigas)
  paraId          = 3165,   -- Paralyze Rune
  avaId           = 3161,   -- Avalanche Rune
  uhId            = 3160,   -- Ultimate Healing Rune
  destroyFieldId  = 3148,   -- Destroy Field
  disintegrateId  = 3197,   -- Disintegrate (remove flores ao redor)
  macheteId       = 3308,   -- Machete / Tramontina
  energyRingId    = 3051,   -- Energy Ring
  trashId         = 3031,   -- Anti-Push: 3031 = Gold | 3035 = Platinum
  flowerIds       = {2981, 2983, 2984, 2985},

  -- Combate
  sdMaxDistance   = 7,      -- Distancia maxima para soltar SD no alvo
  cureSpell       = "exura",-- Magia usada para curar paralyze

  -- Cura
  uhMyMinHp       = 90,     -- So cura amigo se o SEU hp estiver acima disso
  utamoDuration   = 180,    -- Duracao do utamo vita (segundos)
  utamoRenewEarly = 20,     -- Renova X segundos antes de acabar

  -- Energy Ring
  eRingEquipHp    = 40,     -- Equipa abaixo de X% de hp
  eRingUnequipHp  = 70,     -- Desequipa acima de X% de hp

  -- Diversos
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

-- 1.2 Auto SD no alvo (runas infinitas no server) ---------------------------
macro(100, "Auto SD no alvo", function()
  local target = g_game.getAttackingCreature()
  if not target then return end
  local tPos = target:getPosition()
  if tPos.z == posz() and getDistanceBetween(pos(), tPos) <= CONFIG.sdMaxDistance then
    useWith(CONFIG.sdId, target)
    delay(200)
  end
end)

-- 1.3 Icones de runas Max (compartilhados com o IconesDashPack.lua) ----------
-- Cada icone liga/desliga o seu proprio macro e usa a criatura atacada como
-- alvo. A trava evita que os mesmos tres icones sejam criados duas vezes
-- quando os dois packs estiverem carregados no mesmo perfil.
local function addMaxRuneIcon(sharedKey, iconName, itemId, text)
  if not claimSharedIcon(sharedKey) then return end

  local runeMacro = macro(200, function()
    local target = g_game.getAttackingCreature()
    if not target then return end

    useWith(itemId, target)
    delay(200)
  end)

  addIcon(iconName, {item = {id = itemId, count = 1}, text = text}, runeMacro)
end

addMaxRuneIcon("sdMax", "XC_SDMax", CONFIG.sdId, "SDMAX")
addMaxRuneIcon("paraMax", "XC_ParaMax", CONFIG.paraId, "PARAMAX")
addMaxRuneIcon("avaMax", "XC_AvaMax", CONFIG.avaId, "AVAMAX")

-- 1.4 Fast Paralyze Cure (zero delay) ---------------------------------------
macro(20, "Fast Paralyze Cure", function()
  if isParalyzed() then
    say(CONFIG.cureSpell)
    delay(100)
  end
end)

-- 1.5 Auto Destroy Field no pe e flores ao redor -----------------------------
local DANGEROUS_FIELDS = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire
  [2123] = true, [2124] = true, [2125] = true, -- Poison
  [2126] = true, [2127] = true                 -- Energy
}

macro(150, "Auto Destroy Field", function()
  local pPos = pos()
  local tile = g_map.getTile(pPos)
  if not tile then return end

  -- Destroy Field embaixo do personagem tem prioridade.
  for _, item in ipairs(tile:getItems() or {}) do
    if DANGEROUS_FIELDS[item:getId()] then
      useWith(CONFIG.destroyFieldId, item)
      delay(300)
      return
    end
  end

  -- Disintegrate em uma flor por vez nos 8 tiles ao redor.
  for _, off in ipairs(AROUND) do
    local flowerTile = tileAt(pPos, off[1], off[2])
    if flowerTile then
      for _, item in ipairs(flowerTile:getItems() or {}) do
        if table.find(CONFIG.flowerIds, item:getId()) then
          useWith(CONFIG.disintegrateId, item)
          delay(300)
          return
        end
      end
    end
  end
end)


-- 1.5 Safe SD / UE ------------------------------------------------------------
do
-- ============================================================================
-- SAFE SD / UE (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcSafeSd = storage.xcSafeSd or {
  enabled = false,
  Spell = "exevo gran mas frigo",
  safeRange = 8,
  targetDistance = 4
}
local settings = storage.xcSafeSd

if xcSafeSdWindow then xcSafeSdWindow:destroy() end

g_ui.loadUIFromString([[
XcSafeSdWindow < MainWindow
  text: Safe SD/UE Setup
  size: 210 180
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Magia de Area (UE):
    margin-top: 5

  TextEdit
    id: spellText
    margin-top: 3
    text-align: center

  HorizontalSeparator
    margin-top: 8

  Label
    id: rangeLabel
    text-align: center
    text: Distancia Maxima UE: 4 SQMs
    margin-top: 3

  HorizontalScrollBar
    id: distScroll
    minimum: 1
    maximum: 7
    step: 1
    margin-top: 3

  HorizontalSeparator
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

xcSafeSdWindow = UI.createWindow('XcSafeSdWindow', g_ui.getRootWidget())
xcSafeSdWindow:hide()

xcSafeSdWindow.spellText:setText(settings.Spell or "exevo gran mas frigo")
xcSafeSdWindow.spellText.onTextChange = function(w, text)
  settings.Spell = text
end

xcSafeSdWindow.distScroll:setValue(settings.targetDistance or 4)
xcSafeSdWindow.rangeLabel:setText("Distancia Maxima UE: " .. (settings.targetDistance or 4) .. " SQMs")
xcSafeSdWindow.distScroll.onValueChange = function(w, v)
  settings.targetDistance = v
  xcSafeSdWindow.rangeLabel:setText("Distancia Maxima UE: " .. v .. " SQMs")
end

xcSafeSdWindow.closeButton.onClick = function()
  xcSafeSdWindow:hide()
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
    !text: tr('Safe SD/UE')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.setup.onClick = function()
  xcSafeSdWindow:show()
  xcSafeSdWindow:raise()
  xcSafeSdWindow:focus()
end

-- Verifica se tem amigo (party, guild ou lista de amigos) perto o bastante
-- para ser atingido pela área. Não usa isSafe()/isFriend() puros do vBot
-- porque isFriend() NÃO reconhece membro de guild (sem emblema) como amigo,
-- e só reconhece membro de party se a opção "Group Members" da Player List
-- do vBot estiver ligada. Checar o shield (party) e o emblem (guild/ally)
-- diretamente evita soltar UE em cima de guild/party, igual aos outros
-- modulos deste pack (Attack Players, UH No Time, etc).
local function hasFriendNearby(range)
  local pPos = pos()
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      local specPos = spec:getPosition()
      if specPos.z == pPos.z and getDistanceBetween(pPos, specPos) <= range then
        if spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName()) then
          return true
        end
      end
    end
  end
  return false
end

macro(1000, function()
  if not settings.enabled then return end
  local target = g_game.getAttackingCreature()
  if not target then return end

  local maxDist = settings.targetDistance or 4
  local safeRange = settings.safeRange or 8

  if not hasFriendNearby(safeRange) and getDistanceBetween(pos(), target:getPosition()) <= maxDist then
    local spell = settings.Spell
    if spell and spell:match("%S") then
      say(spell)
    end
  else
    useWith(3155, target)
  end
end)
end

-- 1.6 Tela Limpa ------------------------------------------------------------
local telaLimpa = macro(100, "Tela Limpa", function() end)

onStaticText(function(thing, text)
  if telaLimpa:isOff() then return end
  if not text:find("says:") then g_map.cleanTexts() end
end)

onAddThing(function(tile, thing)
  if telaLimpa:isOff() then return end
  if thing and thing:isEffect() then thing:hide() end
end)

onAnimatedText(function(thing, text)
  if telaLimpa:isOff() then return end
  thing:hide()
end)

onTextMessage(function(mode, text)
  if telaLimpa:isOff() then return end
  if mode == 18 or mode == 19 or mode == 20 then
    modules.game_textmessage.clearMessages()
  end
end)


-- 1.7 Combo Attack por missil -------------------------------------------------
do
-- ============================================================================
-- COMBO ATTACK COM LÍDERES (DETECÇÃO DE MÍSSIL/SD)
-- Ataca automaticamente o mesmo alvo do líder no momento em que sai o míssil
-- ============================================================================

storage.xcComboAttack = storage.xcComboAttack or {}
local comboSettings = storage.xcComboAttack

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
end

-- ============================================================================
-- 2. TRAP / MAGIC WALL
-- ============================================================================
section("Trap / MW")

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

-- 2.3 Machete / Tramontina no Wild Growth -----------------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("machete") then
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
end


-- 2.4 Force Hold MW / WG ------------------------------------------------------
do
-- ============================================================================
-- FAST FORCE HOLD MW & WG (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcForceHoldSettings = storage.xcForceHoldSettings or {
  enabled = false,
  mwHotkey = "f3",
  wgHotkey = "f4",
  mwId = 3180,
  wgId = 3156,
  preCastTime = 180
}
local config = storage.xcForceHoldSettings

local mwDuration = 20000
local wgDuration = 45000

storage.xcMwPoses = storage.xcMwPoses or {}
storage.xcWgPoses = storage.xcWgPoses or {}

local wallTimers = {}
local lastCast = {}

local wallIds = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [9598] = true, [9599] = true,
  [10187] = true, [10188] = true, [10189] = true
}

if xcForceHoldWindow then xcForceHoldWindow:destroy() end

g_ui.loadUIFromString([[
XcForceHoldWindow < MainWindow
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

xcForceHoldWindow = UI.createWindow('XcForceHoldWindow', g_ui.getRootWidget())
xcForceHoldWindow:hide()

local function xcfhChild(id)
  local w = xcForceHoldWindow:recursiveGetChildById(id)
  if not w then
    error("[ForceHold] widget nao encontrado na UI: " .. tostring(id))
  end
  return w
end

local xc_mwKeyText = xcfhChild('mwKeyText')
local xc_wgKeyText = xcfhChild('wgKeyText')
local xc_precastScroll = xcfhChild('precastScroll')
local xc_precastLabel = xcfhChild('precastLabel')
local xc_cleanBtn = xcfhChild('cleanBtn')
local xc_closeButton = xcfhChild('closeButton')


xc_mwKeyText:setText(config.mwHotkey or "f3")
xc_mwKeyText.onTextChange = function(w, text)
  config.mwHotkey = text
end

xc_wgKeyText:setText(config.wgHotkey or "f4")
xc_wgKeyText.onTextChange = function(w, text)
  config.wgHotkey = text
end

xc_precastScroll:setValue(config.preCastTime or 180)
xc_precastLabel:setText("Pre-cast: " .. (config.preCastTime or 180) .. "ms")
xc_precastScroll.onValueChange = function(w, v)
  config.preCastTime = v
  xc_precastLabel:setText("Pre-cast: " .. v .. "ms")
end

xc_cleanBtn.onClick = function()
  for _, p in ipairs(storage.xcMwPoses) do
    local tile = g_map.getTile(p)
    if tile then tile:setText("") end
  end
  for _, p in ipairs(storage.xcWgPoses) do
    local tile = g_map.getTile(p)
    if tile then tile:setText("") end
  end
  storage.xcMwPoses = {}
  storage.xcWgPoses = {}
  wallTimers = {}
  lastCast = {}
end

xc_closeButton.onClick = function()
  xcForceHoldWindow:hide()
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
  xcForceHoldWindow:show()
  xcForceHoldWindow:raise()
  xcForceHoldWindow:focus()
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
  local t = millis()
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
  if #storage.xcMwPoses == 0 and #storage.xcWgPoses == 0 then return end
  local pPos = pos()
  local t = millis()
  local preCast = config.preCastTime or 180

  -- MW Loop
  for _, mPos in ipairs(storage.xcMwPoses) do
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
  for _, mPos in ipairs(storage.xcWgPoses) do
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

    local t = millis()
    if not hasWall(tile) then
      castWall(runeId, tile, key, duration)
    else
      wallTimers[key] = t + duration
    end
  end
end

onKeyDown(function(keys)
  if not config.enabled then return end
  keys = keys:lower()
  if keys == (config.mwHotkey or "f3"):lower() then
    togglePos(storage.xcMwPoses, "MW", config.mwId or 3180, mwDuration)
  elseif keys == (config.wgHotkey or "f4"):lower() then
    togglePos(storage.xcWgPoses, "WG", config.wgId or 3156, wgDuration)
  end
end)
end

-- 2.5 Trapa Alvo WG / MW ----------------------------------------------------
do
  storage.xcTargetTrap = storage.xcTargetTrap or {
    enabled = false,
    runeId = 3156
  }
  local config = storage.xcTargetTrap

  if xcTargetTrapWindow then
    xcTargetTrapWindow:destroy()
    xcTargetTrapWindow = nil
  end

  g_ui.loadUIFromString([[
XcTargetTrapWindow < MainWindow
  !text: tr('Trapa Alvo WG/MW Setup')
  size: 220 165
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    id: runeLabel
    text-align: center
    text: "Runa: 3156 WG / 3180 MW"
    margin-top: 5

  BotItem
    id: runeSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    size: 34 34

  HorizontalSeparator
    margin-top: 8

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    margin-top: 5
    margin-left: 155
    size: 45 21
]])

  xcTargetTrapWindow = UI.createWindow('XcTargetTrapWindow', g_ui.getRootWidget())
  xcTargetTrapWindow:hide()
  xcTargetTrapWindow.runeSlot:setItemId(config.runeId)
  xcTargetTrapWindow.runeSlot.onItemChange = function(widget)
    config.runeId = widget:getItemId()
  end
  xcTargetTrapWindow.closeButton.onClick = function()
    xcTargetTrapWindow:hide()
  end

  local trapUi = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 19
    !text: tr('Trapa Alvo WG/MW')

  Button
    id: setup
    anchors.top: title.top
    anchors.left: title.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    !text: tr('Setup')
]], parent)

  trapUi.title:setOn(config.enabled)
  trapUi.title.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setOn(config.enabled)
  end
  trapUi.setup.onClick = function()
    xcTargetTrapWindow:show()
    xcTargetTrapWindow:raise()
    xcTargetTrapWindow:focus()
  end

  local function targetTrapOffsets(playerPos, targetPos)
    local dx = playerPos.x - targetPos.x
    local dy = playerPos.y - targetPos.y

    if math.abs(dx) > math.abs(dy) then
      local side = dx > 0 and -1 or 1
      return {{side, -1}, {side, 0}, {side, 1}}
    end

    local side = dy > 0 and -1 or 1
    return {{-1, side}, {0, side}, {1, side}}
  end

  macro(100, function()
    if not config.enabled then return end

    local target = g_game.getAttackingCreature()
    if not target or not target:isPlayer() then return end

    local playerPos = pos()
    local targetPos = target:getPosition()
    if not targetPos or targetPos.z ~= playerPos.z
      or getDistanceBetween(playerPos, targetPos) > 7 then
      return
    end

    for _, offset in ipairs(targetTrapOffsets(playerPos, targetPos)) do
      local tile = tileAt(targetPos, offset[1], offset[2])
      if tile and tile:isWalkable(false) and not hasWall(tile) then
        if useRuneOnTile(config.runeId, tile) then
          delay(200)
          return
        end
      end
    end
  end)
end

-- 2.6 MW Enemy Step -----------------------------------------------------------
do
-- ============================================================================
-- AUTO MW NO STEP DO INIMIGO (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcMwEnemyStep = storage.xcMwEnemyStep or {
  enabled = false,
  mwId = 3180
}
local config = storage.xcMwEnemyStep

if xcMwStepWindow then xcMwStepWindow:destroy() end

g_ui.loadUIFromString([[
XcMwStepWindow < MainWindow
  text: MW Step Setup
  size: 210 160
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Runa de Magic Wall:
    margin-top: 5

  BotItem
    id: mwSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    width: 34
    height: 34

  HorizontalSeparator
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

xcMwStepWindow = UI.createWindow('XcMwStepWindow', g_ui.getRootWidget())
xcMwStepWindow:hide()

xcMwStepWindow.mwSlot:setItemId(config.mwId or 3180)
xcMwStepWindow.mwSlot.onItemChange = function(w)
  config.mwId = w:getItemId()
end

xcMwStepWindow.closeButton.onClick = function()
  xcMwStepWindow:hide()
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
    !text: tr('MW Enemy Step')

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
  xcMwStepWindow:show()
  xcMwStepWindow:raise()
  xcMwStepWindow:focus()
end

local function isValidEnemy(creature)
  if not creature or not creature:isPlayer() or creature:isLocalPlayer() then
    return false
  end

  local creatureName = creature:getName()
  local lowerName = creatureName:lower()
  local myName = name():lower()
  local shield = creature:getShield() or 0
  local emblem = creature:getEmblem() or 0

  return lowerName ~= myName
    and not isFriend(creatureName)
    and shield < 3
    and emblem ~= 1
end

onCreaturePositionChange(function(creature, newPos, oldPos)
  if not config.enabled then return end

  if isValidEnemy(creature) then
    local localPlayer = g_game.getLocalPlayer()
    if not localPlayer then return end
    local myPosition = localPlayer:getPosition()

    if oldPos and oldPos.z == myPosition.z and getDistanceBetween(myPosition, oldPos) <= 7 then
      local tile = g_map.getTile(oldPos)
      if tile and tile:isWalkable() then
        local target = tile:getTopUseThing() or tile:getGround()
        if target then
          useWith(config.mwId or 3180, target)
        end
      end
    end
  end
end)
end

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
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("utamo") then
  local nextUtamo = 0
  addIcon("XC_Utamo", {item = {id = 3548, count = 1}, text = "Utamo"}, macro(500, function()
    local t = millis()
    if not hasManaShield() or t > nextUtamo then
      say("utamo vita")
      nextUtamo = t + ((CONFIG.utamoDuration - CONFIG.utamoRenewEarly) * 1000)
      delay(500)
    end
  end))
end

-- 3.3 Pot Friend e 3.4 Sio Friend -------------------------------------------
-- Os dois controles ficam em linhas separadas para manter o painel limpo.
storage.xcPotFriend = storage.xcPotFriend or {}
storage.xcSioFriend = storage.xcSioFriend or {}

local potSettings = storage.xcPotFriend
local sioSettings = storage.xcSioFriend

if potSettings.enabled == nil then potSettings.enabled = false end
if potSettings.potion == nil then potSettings.potion = 268 end
if potSettings.manaPercent == nil then potSettings.manaPercent = 50 end
if potSettings.potDistance == nil then potSettings.potDistance = 3 end
if potSettings.talkDelay == nil then potSettings.talkDelay = 2 end
if potSettings.keyword == nil then potSettings.keyword = "p" end
if potSettings.channelName == nil then potSettings.channelName = "party" end
if potSettings.walkToPot == nil then potSettings.walkToPot = true end

if sioSettings.enabled == nil then sioSettings.enabled = false end
if sioSettings.friendHp == nil then sioSettings.friendHp = 70 end
if sioSettings.minMyHp == nil then sioSettings.minMyHp = 50 end

-- Remove janelas antigas ao recarregar o pack.
if xcPotFriendWindow then
  xcPotFriendWindow:destroy()
  xcPotFriendWindow = nil
end
if xcSioFriendWindow then
  xcSioFriendWindow:destroy()
  xcSioFriendWindow = nil
end

g_ui.loadUIFromString([[
XcPotScrollBar < Panel
  height: 28
  margin-top: 3

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  HorizontalScrollBar
    id: scroll
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 100
    step: 1

XcPotTextEdit < Panel
  height: 40
  margin-top: 7

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  TextEdit
    id: textEdit
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: center

XcPotItem < Panel
  height: 34
  margin-top: 7
  margin-left: 20
  margin-right: 20

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.verticalCenter: next.verticalCenter

  BotItem
    id: item
    anchors.top: parent.top
    anchors.right: parent.right

XcPotCheckBox < BotSwitch
  height: 20
  margin-top: 7

XcPotFriendWindow < MainWindow
  !text: tr('Pot Friend Setup')
  size: 420 330
  padding: 15
  @onEscape: self:hide()

  ScrollablePanel
    id: content
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin-bottom: 8

    Panel
      id: left
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.horizontalCenter
      margin-right: 8
      layout:
        type: verticalBox
        fit-children: true

    Panel
      id: right
      anchors.top: parent.top
      anchors.left: parent.horizontalCenter
      anchors.right: parent.right
      margin-left: 8
      layout:
        type: verticalBox
        fit-children: true

    VerticalSeparator
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.horizontalCenter

  HorizontalSeparator
    id: separator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: closeButton.top
    margin-bottom: 8

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 50 21

XcSioFriendWindow < MainWindow
  !text: tr('Sio Friend Setup')
  size: 230 180
  padding: 15
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    id: friendHpLabel
    text-align: center
    text: Curar amigos abaixo de: 70% HP
    margin-top: 5

  HorizontalScrollBar
    id: friendHpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 5

  HorizontalSeparator
    margin-top: 8

  Label
    id: myHpLabel
    text-align: center
    text: Meu HP minimo para Sio: 50%
    margin-top: 3

  HorizontalScrollBar
    id: myHpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 5

  HorizontalSeparator
    margin-top: 8

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    margin-top: 5
    margin-left: 155
    width: 45
    height: 21
]])

xcPotFriendWindow = UI.createWindow('XcPotFriendWindow', g_ui.getRootWidget())
xcPotFriendWindow:hide()
xcPotFriendWindow.closeButton.onClick = function()
  xcPotFriendWindow:hide()
end

local potLeftPanel = xcPotFriendWindow.content.left
local potRightPanel = xcPotFriendWindow.content.right

local function addPotCheckBox(id, title, defaultValue, destination)
  local widget = UI.createWidget('XcPotCheckBox', destination)
  widget:setText(title)
  if potSettings[id] == nil then potSettings[id] = defaultValue end
  widget:setOn(potSettings[id])
  widget.onClick = function()
    widget:setOn(not widget:isOn())
    potSettings[id] = widget:isOn()
  end
end

local function addPotItem(id, title, defaultItem, destination)
  local widget = UI.createWidget('XcPotItem', destination)
  if potSettings[id] == nil then potSettings[id] = defaultItem end
  widget.text:setText(title)
  widget.item:setItemId(potSettings[id])
  widget.item.onItemChange = function(itemWidget)
    potSettings[id] = itemWidget:getItemId()
  end
end

local function addPotTextEdit(id, title, defaultValue, destination)
  local widget = UI.createWidget('XcPotTextEdit', destination)
  if potSettings[id] == nil then potSettings[id] = defaultValue end
  widget.text:setText(title)
  widget.textEdit:setText(potSettings[id])
  widget.textEdit.onTextChange = function(_, text)
    potSettings[id] = text
  end
end

local function addPotScrollBar(id, title, minimum, maximum, defaultValue, destination)
  local widget = UI.createWidget('XcPotScrollBar', destination)
  if potSettings[id] == nil then potSettings[id] = defaultValue end
  widget.scroll:setRange(minimum, maximum)
  widget.scroll:setValue(potSettings[id])
  widget.text:setText(title:gsub("#v", widget.scroll:getValue()))
  widget.scroll.onValueChange = function(_, value)
    potSettings[id] = value
    widget.text:setText(title:gsub("#v", value))
  end
end

addPotItem("potion", "Potion", 268, potLeftPanel)
addPotScrollBar("manaPercent", "Pedir pot com #v% MP", 0, 100, 50, potLeftPanel)
addPotScrollBar("potDistance", "Distancia max: #v SQMs", 0, 8, 3, potLeftPanel)
addPotScrollBar("talkDelay", "Delay de fala: #vs", 0, 10, 2, potLeftPanel)
addPotTextEdit("keyword", "Palavra-chave", "p", potLeftPanel)
addPotTextEdit("channelName", "Chat (party/guild)", "party", potRightPanel)
addPotCheckBox("walkToPot", "Andar ate amigos para potar", true, potRightPanel)

xcSioFriendWindow = UI.createWindow('XcSioFriendWindow', g_ui.getRootWidget())
xcSioFriendWindow:hide()
xcSioFriendWindow.closeButton.onClick = function()
  xcSioFriendWindow:hide()
end

xcSioFriendWindow.friendHpScroll:setValue(sioSettings.friendHp)
xcSioFriendWindow.friendHpLabel:setText("Curar amigos abaixo de: " .. sioSettings.friendHp .. "% HP")
xcSioFriendWindow.friendHpScroll.onValueChange = function(_, value)
  sioSettings.friendHp = value
  xcSioFriendWindow.friendHpLabel:setText("Curar amigos abaixo de: " .. value .. "% HP")
end

xcSioFriendWindow.myHpScroll:setValue(sioSettings.minMyHp)
xcSioFriendWindow.myHpLabel:setText("Meu HP minimo para Sio: " .. sioSettings.minMyHp .. "%")
xcSioFriendWindow.myHpScroll.onValueChange = function(_, value)
  sioSettings.minMyHp = value
  xcSioFriendWindow.myHpLabel:setText("Meu HP minimo para Sio: " .. value .. "%")
end

-- Uma linha para cada script evita espremer os nomes e os botoes de setup.
local friendSupportUi = setupUI([[
Panel
  height: 42

  BotSwitch
    id: potTitle
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 19
    !text: tr('Pot Friend')

  Button
    id: potSetup
    anchors.top: potTitle.top
    anchors.left: potTitle.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    !text: tr('Setup')

  BotSwitch
    id: sioTitle
    anchors.top: potTitle.bottom
    anchors.left: parent.left
    margin-top: 3
    text-align: center
    width: 130
    height: 19
    !text: tr('Sio Friend')

  Button
    id: sioSetup
    anchors.top: sioTitle.top
    anchors.left: sioTitle.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    !text: tr('Setup')
]], parent)

friendSupportUi.potTitle:setOn(potSettings.enabled)
friendSupportUi.potTitle.onClick = function(widget)
  potSettings.enabled = not potSettings.enabled
  widget:setOn(potSettings.enabled)
end
friendSupportUi.potSetup.onClick = function()
  xcPotFriendWindow:show()
  xcPotFriendWindow:raise()
  xcPotFriendWindow:focus()
end

friendSupportUi.sioTitle:setOn(sioSettings.enabled)
friendSupportUi.sioTitle.onClick = function(widget)
  sioSettings.enabled = not sioSettings.enabled
  widget:setOn(sioSettings.enabled)
end
friendSupportUi.sioSetup.onClick = function()
  xcSioFriendWindow:show()
  xcSioFriendWindow:raise()
  xcSioFriendWindow:focus()
end

-- Pede potion no canal configurado quando a mana fica abaixo do limite.
macro(1000, function()
  if not potSettings.enabled then return end
  if manapercent() > potSettings.manaPercent then return end

  local channel = getChannelId(potSettings.channelName)
  if channel then
    sayChannel(channel, potSettings.keyword)
    delay(potSettings.talkDelay * 1000)
  end
end)

-- Envia duas potions para um amigo de party/guild que disser a palavra-chave.
onTalk(function(authorName, level, mode, text, channelId, talkPosition)
  if not potSettings.enabled then return end
  if authorName:lower() == name():lower() then return end
  if text:lower() ~= potSettings.keyword:lower() then return end

  local friend = getCreatureByName(authorName)
  if not friend then return end
  if friend:getEmblem() ~= 1 and friend:getShield() < 3 and not isFriend(authorName) then return end

  local friendPosition = friend:getPosition()
  local myPosition = pos()
  if not friendPosition or friendPosition.z ~= myPosition.z then return end
  if getDistanceBetween(myPosition, friendPosition) > potSettings.potDistance then return end

  if potSettings.walkToPot and getDistanceBetween(myPosition, friendPosition) > 1 then
    autoWalk(friendPosition, 10, {precision = 1, ignoreCreatures = true})
  end

  useWith(potSettings.potion, friend)

  schedule(350, function()
    local currentFriend = getCreatureByName(authorName)
    if not currentFriend then return end
    local currentPosition = currentFriend:getPosition()
    if currentPosition and currentPosition.z == posz()
      and getDistanceBetween(pos(), currentPosition) <= potSettings.potDistance then
      useWith(potSettings.potion, currentFriend)
    end
  end)
end)

-- Cura o amigo de party/guild com o menor HP dentro do limite configurado.
macro(200, function()
  if not sioSettings.enabled then return end
  if hppercent() < sioSettings.minMyHp then return end

  local lowestFriend, lowestHp = nil, 101
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer()
      and (spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName())) then
      local friendHp = spec:getHealthPercent()
      if friendHp > 0 and friendHp <= sioSettings.friendHp and friendHp < lowestHp then
        lowestFriend, lowestHp = spec, friendHp
      end
    end
  end

  if lowestFriend then
    say('exura sio "' .. lowestFriend:getName())
    delay(400)
  end
end)

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


-- 4.2 Energy Ring ---------------------------------------------------
do
-- ============================================================================
-- EMERGENCY ENERGY RING SWAPPER (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcEmergencyRing = storage.xcEmergencyRing or {
  enabled = false,
  secRingId = 3048,
  equipHp = 60,
  unequipHp = 80
}
local config = storage.xcEmergencyRing
local eRingId = 3051

if xcEmergencyRingWindow then xcEmergencyRingWindow:destroy() end

g_ui.loadUIFromString([[
XcEmergencyRingWindow < MainWindow
  text: Energy Ring Setup
  size: 210 230
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Anel Principal (Normal)
    margin-top: 5

  HorizontalSeparator
    margin-top: 3

  BotItem
    id: ringSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    width: 34
    height: 34

  HorizontalSeparator
    margin-top: 8

  Label
    id: equipLabel
    text-align: center
    text: Equipa Energy se HP <= 60%
    margin-top: 3

  HorizontalScrollBar
    id: equipScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 2

  Label
    id: unequipLabel
    text-align: center
    text: Tira Energy se HP >= 80%
    margin-top: 5

  HorizontalScrollBar
    id: unequipScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 2

  HorizontalSeparator
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

xcEmergencyRingWindow = UI.createWindow('XcEmergencyRingWindow', g_ui.getRootWidget())
xcEmergencyRingWindow:hide()

xcEmergencyRingWindow.ringSlot:setItemId(config.secRingId)
xcEmergencyRingWindow.ringSlot.onItemChange = function(w)
  config.secRingId = w:getItemId()
end

xcEmergencyRingWindow.equipScroll:setValue(config.equipHp)
xcEmergencyRingWindow.equipLabel:setText("Equipa Energy se HP <= " .. config.equipHp .. "%")
xcEmergencyRingWindow.equipScroll.onValueChange = function(w, v)
  config.equipHp = v
  xcEmergencyRingWindow.equipLabel:setText("Equipa Energy se HP <= " .. v .. "%")
end

xcEmergencyRingWindow.unequipScroll:setValue(config.unequipHp)
xcEmergencyRingWindow.unequipLabel:setText("Tira Energy se HP >= " .. config.unequipHp .. "%")
xcEmergencyRingWindow.unequipScroll.onValueChange = function(w, v)
  config.unequipHp = v
  xcEmergencyRingWindow.unequipLabel:setText("Tira Energy se HP >= " .. v .. "%")
end

xcEmergencyRingWindow.closeButton.onClick = function()
  xcEmergencyRingWindow:hide()
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
    !text: tr('Energy Ring')

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
  xcEmergencyRingWindow:show()
  xcEmergencyRingWindow:raise()
  xcEmergencyRingWindow:focus()
end

macro(250, function()
  if not config.enabled then return end

  local hp = hppercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local normalRingId = config.secRingId or 0

  if hp <= config.equipHp then
    if currentRingId ~= eRingId then
      local eRingItem = findItem(eRingId)
      if eRingItem then
        moveToSlot(eRingItem, SlotFinger)
        delay(400)
      end
    end
  elseif hp >= config.unequipHp then
    if normalRingId > 0 and currentRingId ~= normalRingId then
      local normalRingItem = findItem(normalRingId)
      if normalRingItem then
        moveToSlot(normalRingItem, SlotFinger)
        delay(400)
      end
    end
  end
end)
end

-- 4.3 Ring Invertido ------------------------------------------------------
do
-- ============================================================================
-- SMART RING SWAPPER (RING INVERTIDO - COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcSmartRing = storage.xcSmartRing or {
  enabled = false,
  secRingId = 14557,
  hpEquip = 85,
  mpEquip = 60
}
local config = storage.xcSmartRing
local eRingId = 3051 -- Energy Ring fixo

if xcSmartRingWindow then xcSmartRingWindow:destroy() end

g_ui.loadUIFromString([[
XcSmartRingWindow < MainWindow
  text: Ring Invertido Setup
  size: 210 245
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Anel Secundario (Normal)
    margin-top: 5

  HorizontalSeparator
    margin-top: 3

  BotItem
    id: ringSlot
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 5
    width: 34
    height: 34

  HorizontalSeparator
    margin-top: 8

  Label
    id: hpLabel
    text-align: center
    text: Equipa Energy se HP <= 85%
    margin-top: 5

  HorizontalScrollBar
    id: hpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 3

  Label
    id: mpLabel
    text-align: center
    text: Mantem Energy se Mana >= 60%
    margin-top: 5

  HorizontalScrollBar
    id: mpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 3

  HorizontalSeparator
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

xcSmartRingWindow = UI.createWindow('XcSmartRingWindow', g_ui.getRootWidget())
xcSmartRingWindow:hide()

xcSmartRingWindow.ringSlot:setItemId(config.secRingId)
xcSmartRingWindow.ringSlot.onItemChange = function(w)
  config.secRingId = w:getItemId()
end

xcSmartRingWindow.hpScroll:setValue(config.hpEquip)
xcSmartRingWindow.hpLabel:setText("Equipa Energy se HP <= " .. config.hpEquip .. "%")
xcSmartRingWindow.hpScroll.onValueChange = function(w, v)
  config.hpEquip = v
  xcSmartRingWindow.hpLabel:setText("Equipa Energy se HP <= " .. v .. "%")
end

xcSmartRingWindow.mpScroll:setValue(config.mpEquip)
xcSmartRingWindow.mpLabel:setText("Mantem Energy se Mana >= " .. config.mpEquip .. "%")
xcSmartRingWindow.mpScroll.onValueChange = function(w, v)
  config.mpEquip = v
  xcSmartRingWindow.mpLabel:setText("Mantem Energy se Mana >= " .. v .. "%")
end

xcSmartRingWindow.closeButton.onClick = function()
  xcSmartRingWindow:hide()
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
    !text: tr('Ring Invertido')

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
  xcSmartRingWindow:show()
  xcSmartRingWindow:raise()
  xcSmartRingWindow:focus()
end

macro(400, function()
  if not config.enabled then return end

  local hp = hppercent()
  local mp = manapercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local configuredRing = config.secRingId or 14557

  if hp <= config.hpEquip or (hp > config.hpEquip and mp >= config.mpEquip) then
    if currentRingId ~= eRingId then
      local ringItem = findItem(eRingId)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500)
      end
    end
  elseif hp > config.hpEquip and mp < config.mpEquip then
    if configuredRing > 0 and currentRingId ~= configuredRing then
      local ringItem = findItem(configuredRing)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500)
      end
    end
  end
end)
end

-- ============================================================================
-- 5. MOVIMENTACAO
-- ============================================================================
section("Movimentacao")

-- 5.1 Auto Chase (sem spam de pacotes) --------------------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("chase") then
  addIcon("XC_Chase", {item = {id = 3555, count = 1}, text = "Chase"}, macro(500, function()
    if g_game.getChaseMode() ~= 1 then
      g_game.setChaseMode(1)
    end
  end))
end

-- 5.2 Auto Mount ao sair do PZ ----------------------------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("mount") then
  addIcon("XC_Mount", {item = {id = 390, count = 1}, text = "Mount"}, macro(3000, function()
    if isInPz() then return end
    local p = g_game.getLocalPlayer()
    if p and not p:isMounted() then p:mount() end
  end))
end

-- 5.3 Auto Invis (utana vid) -------------------------------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("invis") then
  addIcon("XC_Invis", {item = {id = 2202, count = 1}, text = "Invis"}, macro(5000, function()
    local p = g_game.getLocalPlayer()
    if p and not p:isInvisible() and not isInPz() then
      say("utana vid")
    end
  end))
end

-- 5.4 Bug Map Dash (W A S D / setas) ----------------------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("dash") then
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
end

-- 5.5 Anti-Push com moedas (impede que te empurrem) -------------------------
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

-- 5.6 Flores nos 8 SQMs ao redor (anti-trap / anti-push) ---------------------
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
-- 6. UTILITARIOS E AUTOMACAO
-- ============================================================================
section("Utilitarios & Automacao")

-- 6.1 Pick-Up Items -----------------------------------------------------------
do
-- ============================================================================
-- PICK-UP ITENS (CATAR ITENS DO CHÃO)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.xcPickEnabled = storage.xcPickEnabled or 0
storage.xcPickUp = type(storage.xcPickUp) == "table" and storage.xcPickUp or {3725, 3723}
storage.xcContainerPickUp = type(storage.xcContainerPickUp) == "table" and storage.xcContainerPickUp or {5926}
storage.xcPickRange = type(storage.xcPickRange) == "number" and storage.xcPickRange or 1

if xcPickupSetupWindow then xcPickupSetupWindow:destroy() end

g_ui.loadUIFromString([[
XcPickupSetupWindow < MainWindow
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

xcPickupSetupWindow = UI.createWindow('XcPickupSetupWindow', g_ui.getRootWidget())
xcPickupSetupWindow:hide()

local pickUpContainer = UI.Container(function(widget, items)
  storage.xcPickUp = items
end, true)
pickUpContainer:setParent(xcPickupSetupWindow.pickOnlyPanel)
pickUpContainer:fill('parent')
pickUpContainer:setItems(storage.xcPickUp)

local containerpickUpContainer = UI.Container(function(widget, items)
  storage.xcContainerPickUp = items
end, true)
containerpickUpContainer:setParent(xcPickupSetupWindow.pickContainerPanel)
containerpickUpContainer:fill('parent')
containerpickUpContainer:setItems(storage.xcContainerPickUp)

xcPickupSetupWindow.closeButton.onClick = function()
  xcPickupSetupWindow:hide()
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

pickUI.rangeScroll:setValue(storage.xcPickRange)
pickUI.rangeLabel:setText("Range: " .. storage.xcPickRange .. " tiles")
pickUI.rangeScroll.onValueChange = function(widget, value)
  storage.xcPickRange = value
  pickUI.rangeLabel:setText("Range: " .. value .. " tiles")
end

pickUI.btnSetup.onClick = function()
  xcPickupSetupWindow:show()
  xcPickupSetupWindow:raise()
  xcPickupSetupWindow:focus()
end

-- Macro Otimizado de Pick-Up (200ms com busca rápida O(1))
macro(200, function()
  if storage.xcPickEnabled ~= 1 or freecap() < 150 or not storage.xcPickUp[1] then return end

  local pickMap = {}
  for _, item in ipairs(storage.xcPickUp) do
    local id = type(item) == "table" and item.id or item
    if id then pickMap[id] = true end
  end

  local destBpMap = {}
  for _, bp in ipairs(storage.xcContainerPickUp) do
    local id = type(bp) == "table" and bp.id or bp
    if id then destBpMap[id] = true end
  end

  local pPos = pos()
  local r = storage.xcPickRange

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

pickUI.status:setOn(storage.xcPickEnabled == 1)
pickUI.status.onClick = function(widget)
  storage.xcPickEnabled = storage.xcPickEnabled == 1 and 0 or 1
  widget:setOn(storage.xcPickEnabled == 1)
end
end

-- 6.2 Stamina Items -----------------------------------------------------------
do
-- ============================================================================
-- STAMINA ITEMS (USO AUTOMÁTICO DE REGEN DE STAMINA)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local panelName = "xcStaminaItemsUser"
storage[panelName] = storage[panelName] or { min = 0, max = 40, items = {11588} }
if type(storage[panelName].items) ~= "table" then storage[panelName].items = {11588} end
storage.xcStaminaEnabled = storage.xcStaminaEnabled or 0

if xcStaminaSetupWindow then xcStaminaSetupWindow:destroy() end

g_ui.loadUIFromString([[
XcStaminaSetupWindow < MainWindow
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

xcStaminaSetupWindow = UI.createWindow('XcStaminaSetupWindow', g_ui.getRootWidget())
xcStaminaSetupWindow:hide()

local function updateText()
  xcStaminaSetupWindow.lblRange:setText(storage[panelName].min .. " <= Stamina <= " .. storage[panelName].max)
end

xcStaminaSetupWindow.scroll1:setValue(storage[panelName].min)
xcStaminaSetupWindow.scroll2:setValue(storage[panelName].max)
updateText()

xcStaminaSetupWindow.scroll1.onValueChange = function(w, v)
  storage[panelName].min = math.min(v, storage[panelName].max)
  if storage[panelName].min ~= v then w:setValue(storage[panelName].min) end
  updateText()
end
xcStaminaSetupWindow.scroll2.onValueChange = function(w, v)
  storage[panelName].max = math.max(v, storage[panelName].min)
  if storage[panelName].max ~= v then w:setValue(storage[panelName].max) end
  updateText()
end

for i = 1, 5 do
  xcStaminaSetupWindow.items:getChildByIndex(i).onItemChange = function(w)
    storage[panelName].items[i] = w:getItemId()
  end
  xcStaminaSetupWindow.items:getChildByIndex(i):setItemId(storage[panelName].items[i])
end

xcStaminaSetupWindow.closeButton.onClick = function()
  xcStaminaSetupWindow:hide()
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
]], parent)

staminaUI.btnSetup.onClick = function()
  xcStaminaSetupWindow:show()
  xcStaminaSetupWindow:raise()
  xcStaminaSetupWindow:focus()
end

macro(1000, function()
  if storage.xcStaminaEnabled ~= 1 then return end
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

staminaUI.status:setOn(storage.xcStaminaEnabled == 1)
staminaUI.status.onClick = function(widget)
  storage.xcStaminaEnabled = storage.xcStaminaEnabled == 1 and 0 or 1
  widget:setOn(storage.xcStaminaEnabled == 1)
end
end

-- 6.3 Vende Tudo --------------------------------------------------------------
do
-- ============================================================================
-- VENDE TUDO (OTIMIZADO COM TABELA HASH O(1))
-- Vende os itens da lista usando a Sell Wand sem travamentos
-- ============================================================================

local sellWand = 7426
storage.xcSellEnabled = storage.xcSellEnabled or 0
if type(storage.xcItemsToSell) ~= "table" then
  storage.xcItemsToSell = {
    822, 7412, 7388, 3554, 7423, 7422, 32208, 32209, 8074, 821, 823,
    32187, 32188, 16126, 3364, 3281, 3366, 3071, 3280, 3420, 3079,
    3392, 7402, 3386, 32185, 32186, 3360, 3342, 3370, 7430, 8057,
    3414, 32180, 32179, 32178, 3063, 826, 7382,
    41971, 41968, 41969, 41970, 41966, 41965, 41967
  }
end

if xcSellSetupWindow then xcSellSetupWindow:destroy() end

g_ui.loadUIFromString([[
XcSellSetupWindow < MainWindow
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

xcSellSetupWindow = UI.createWindow('XcSellSetupWindow', g_ui.getRootWidget())
xcSellSetupWindow:hide()

local sellContainer = UI.Container(function(widget, items)
  storage.xcItemsToSell = items
end, true)
sellContainer:setParent(xcSellSetupWindow.sellContainer)
sellContainer:fill('parent')
sellContainer:setItems(storage.xcItemsToSell)

xcSellSetupWindow.closeButton.onClick = function()
  xcSellSetupWindow:hide()
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
  xcSellSetupWindow:show()
  xcSellSetupWindow:raise()
  xcSellSetupWindow:focus()
end

macro(200, function()
  if storage.xcSellEnabled ~= 1 then return end

  local sellMap = {}
  for _, it in ipairs(storage.xcItemsToSell) do
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

sellUI.status:setOn(storage.xcSellEnabled == 1)
sellUI.status.onClick = function(widget)
  storage.xcSellEnabled = storage.xcSellEnabled == 1 and 0 or 1
  widget:setOn(storage.xcSellEnabled == 1)
end
end

-- ============================================================================
-- 7. HUD & INTERFACE
-- ============================================================================
section("HUD & Interface")

-- 7.1 Target HUD (nick / hp / distancia) -------------------------------------
-- O HUD fica no rootWidget (e nao dentro do painel do bot), no topo central da
-- tela. Ele mostra qualquer criatura atacada, nao apenas jogadores.
if xcTargetHud then
  xcTargetHud:destroy()
  xcTargetHud = nil
end

xcTargetHud = setupUI([[
Panel
  id: xcTargetHud
  width: 420
  height: 24
  background-color: #101010dd
  border: 1 #ff5555
  phantom: true
  anchors.top: parent.top
  anchors.horizontalCenter: parent.horizontalCenter
  margin-top: 35

  Label
    id: text
    anchors.fill: parent
    font: verdana-11px-rounded
    color: #ff5555
    text-align: center
    text: "TARGET HUD: nenhum alvo"
]], g_ui.getRootWidget())

local targetHudText = xcTargetHud:getChildById('text')
xcTargetHud:show()
xcTargetHud:raise()

macro(100, "Target HUD", function()
  local target = g_game.getAttackingCreature()
  local targetPos = target and target:getPosition()
  local myPos = pos()

  if target and targetPos and myPos then
    local hp = math.floor(tonumber(target:getHealthPercent()) or 0)
    local distance = math.floor(getDistanceBetween(myPos, targetPos) or 0)
    local targetType = target:isPlayer() and "PLAYER" or "CREATURE"

    targetHudText:setText(string.format("ALVO %s: %s | HP: %d%% | DIST: %d",
      targetType, target:getName() or "?", hp, distance))
  else
    -- Deixa uma mensagem curta visivel para confirmar que o HUD esta ativo.
    targetHudText:setText("TARGET HUD: ataque um alvo para ver HP e distancia")
  end

  xcTargetHud:show()
end)

-- 7.2 Coordenadas no minimapa ------------------------------------------------
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

-- 7.3 Icones CaveBot / TargetBot com indicador ON-OFF ------------------------
-- (compartilhado com o IconesDashPack.lua, ver claimSharedIcon no topo)
if claimSharedIcon("caveTargetIcons") then
  local cIcon, tIcon

  if CaveBot then
    cIcon = addIcon("XC_Cave", {text = "Cave\nBot", switchable = false, moveable = true}, function()
      if CaveBot.isOff() then CaveBot.setOn() else CaveBot.setOff() end
    end)
    cIcon:setSize({height = 30, width = 50})
    cIcon.text:setFont('verdana-11px-rounded')
  end

  if TargetBot then
    tIcon = addIcon("XC_Target", {text = "Target\nBot", switchable = false, moveable = true}, function()
      if TargetBot.isOff() then TargetBot.setOn() else TargetBot.setOff() end
    end)
    tIcon:setSize({height = 30, width = 50})
    tIcon.text:setFont('verdana-11px-rounded')
  end

  macro(300, function()
    if cIcon and CaveBot then
      if CaveBot.isOn() then
        cIcon.text:setColoredText({"CaveBot\n", "white", "ON", "green"})
      else
        cIcon.text:setColoredText({"CaveBot\n", "white", "OFF", "red"})
      end
    end

    if tIcon and TargetBot then
      if TargetBot.isOn() then
        tIcon.text:setColoredText({"Target\n", "white", "ON", "green"})
      else
        tIcon.text:setColoredText({"Target\n", "white", "OFF", "red"})
      end
    end
  end)
end

setDefaultTab("Main")
