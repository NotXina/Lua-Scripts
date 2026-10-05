-- ============================================================================
--                       XINA CORE PACK  -  OTCv8 3.2 / vBot 4.8
-- ----------------------------------------------------------------------------
--  Pack unico e organizado com os modulos avulsos deste repositorio.
--  Tudo fica dentro da aba "Xina Core", dividido por secoes:
--
--    1. COMBATE          -> Attack Players (menor HP), Auto SD no alvo,
--                           Fast Paralyze Cure, Auto Destroy Field
--    2. TRAP / MW        -> MW Self Step, Trapa em si (MW), Machete no WG
--    3. CURA & SUPORTE   -> UH No Time, Renew Utamo Vita, Pot Friend,
--                           Sio Friend
--    4. EQUIPAMENTOS     -> Smart Energy Ring
--    5. MOVIMENTACAO     -> Auto Chase, Auto Mount, Auto Invis, Bug Map Dash,
--                           Anti-Push (moedas), Flores ao redor
--    6. HUD & INTERFACE  -> Target HUD, Coordenadas no minimapa,
--                           Icones CaveBot / TargetBot
--
--  Versao enxuta: ficaram de fora Trap WG diagonais e o Timer visual de MW
--  (gasta runa a toa / da lag). Continuam disponiveis como scripts avulsos.
--
--  Todos os modulos comecam DESLIGADOS. Ligue pelo painel do bot ou pelos
--  icones na tela. Ajuste os itens gerais na tabela CONFIG; Pot Friend e
--  Sio Friend possuem janelas proprias de Setup.
--
--  AVISO: nao carregue este pack junto com os scripts avulsos equivalentes
--  (MWSelfStep.lua, AutoChase.lua, PotFriend.lua, AutoSioParty.lua, etc)
--  para nao duplicar macros, callbacks e hotkeys.
-- ============================================================================

-- ============================================================================
-- CONFIGURACOES GERAIS
-- ============================================================================
local CONFIG = {
  -- Runas e itens
  mwId            = 3180,   -- Magic Wall      (2293 em 7.4/8.0)
  sdId            = 3155,   -- Sudden Death    (2268 em versoes antigas)
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

-- 1.3 Fast Paralyze Cure (zero delay) ---------------------------------------
macro(20, "Fast Paralyze Cure", function()
  if isParalyzed() then
    say(CONFIG.cureSpell)
    delay(100)
  end
end)

-- 1.4 Auto Destroy Field no pe e flores ao redor -----------------------------
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
