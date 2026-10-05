-- ============================================================================
--                     ICONES & DASH PACK (OTIMIZADO)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ----------------------------------------------------------------------------
-- COMPATÍVEL COM XinaCorePack.lua:
-- Machete, ícones de CaveBot/TargetBot, Dash, Invis, Mount, Utamo e Chase
-- também existem dentro do XinaCorePack.lua (secoes 2, 3, 5 e 7). Os dois
-- arquivos podem ficar ligados ao mesmo tempo no mesmo perfil: cada módulo
-- usa "claimSharedIcon" (ver abaixo) para garantir que só UM dos dois
-- scripts crie aquele ícone/macro/hotkey. Isso evita ícone duplicado na
-- tela, hotkey duplicada (ex.: F1 e NumPad0) e o dobro de timers rodando
-- ao mesmo tempo (= menos lag). Quem carrega primeiro "ganha" o módulo; se
-- só um dos dois arquivos estiver ativo, ele cria tudo normalmente.
-- ============================================================================

-- ============================================================================
-- 0. TRAVA COMPARTILHADA (evita duplicar módulos com o XinaCorePack.lua)
-- ============================================================================
xinaSharedIcons = xinaSharedIcons or {}

-- O g_clock não é exposto por todas as versões do OTCv8/vBot. Usa o relógio
-- do vBot quando disponível e mantém fallbacks compatíveis para o carregamento.
local function millis()
  if type(now) == "number" then return now end
  if g_clock and type(g_clock.millis) == "function" then return g_clock.millis() end
  return os.time() * 1000
end

-- "Reivindica" um módulo compartilhado. Retorna true só para quem chamar
-- primeiro; expira sozinha depois de alguns segundos para não "perder" o
-- ícone caso os scripts sejam recarregados em momentos diferentes (ex.:
-- editar e salvar só um dos dois arquivos no bot).
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
-- 1. FUNÇÕES AUXILIARES
-- ============================================================================
local function getNearTiles(centerPos)
  if not centerPos then return {} end
  local tiles = {}
  local offsets = {
    {-1, 1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {-1, -1}, {0, -1}, {1, -1}
  }
  for _, off in ipairs(offsets) do
    local tile = g_map.getTile({
      x = centerPos.x - off[1],
      y = centerPos.y - off[2],
      z = centerPos.z
    })
    if tile then table.insert(tiles, tile) end
  end
  return tiles
end

-- ============================================================================
-- 2. MACHETE NO WG (TRAMONTINA)
-- ============================================================================
if claimSharedIcon("machete") then
  local macheteConfig = {
    macheteId = 3308,
    hotkey = "F1",
    wgWallId = 2130
  }

  addIcon("TramontinaIcon", {item = {id = macheteConfig.macheteId, count = 1}, text = "Machete", hotkey = macheteConfig.hotkey}, macro(200, function()
    for _, tile in ipairs(getNearTiles(pos())) do
      local topThing = tile:getTopThing()
      if topThing and topThing:getId() == macheteConfig.wgWallId then
        useWith(macheteConfig.macheteId, topThing)
        return
      end
    end
  end))
end

-- ============================================================================
-- 3. ÍCONES CAVEBOT & TARGETBOT (COM INDICADOR ON/OFF LEVE)
-- ============================================================================
if claimSharedIcon("caveTargetIcons") then
  local cIcon = addIcon("cI", {text = "Cave\nBot", switchable = false, moveable = true}, function()
    if CaveBot.isOff() then CaveBot.setOn() else CaveBot.setOff() end
  end)
  cIcon:setSize({height = 30, width = 50})
  cIcon.text:setFont('verdana-11px-rounded')

  local tIcon = addIcon("tI", {text = "Target\nBot", switchable = false, moveable = true}, function()
    if TargetBot.isOff() then TargetBot.setOn() else TargetBot.setOff() end
  end)
  tIcon:setSize({height = 30, width = 50})
  tIcon.text:setFont('verdana-11px-rounded')

  -- Atualização leve a cada 300ms (Sem lag de renderização)
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

-- ============================================================================
-- 4. DASH (BUG MAP / MAP CLICK)
-- ============================================================================
if claimSharedIcon("dash") then
  local function checkPos(offX, offY)
    local localPlayer = g_game.getLocalPlayer()
    if not localPlayer then return end
    local pPos = localPlayer:getPosition()

    local targetPos = {x = pPos.x + offX, y = pPos.y + offY, z = pPos.z}
    local tile = g_map.getTile(targetPos)
    if tile then
      local top = tile:getTopUseThing()
      if top then
        g_game.use(top)
      end
    end
  end

  local bugMap = macro(25, function()
    -- g_keyboard é global do OTClientV8 (corelib/keyboard.lua) e já é exposto
    -- no contexto do bot. "modules.corelib.g_keyboard" é nil e quebra o macro.
    local kb = g_keyboard
    if kb.isKeyPressed('Up') or kb.isKeyPressed('w') then
      checkPos(0, -5)
    elseif kb.isKeyPressed('Right') or kb.isKeyPressed('d') then
      checkPos(5, 0)
    elseif kb.isKeyPressed('Down') or kb.isKeyPressed('s') then
      checkPos(0, 5)
    elseif kb.isKeyPressed('Left') or kb.isKeyPressed('a') then
      checkPos(-5, 0)
    end
  end)
  bugMap.setOff()

  addIcon("Bug Map", {item = 3368, text = "DASH", hotkey = "NumPad0"}, function(icon, isOn)
    modules.game_console.consoleTextEdit:setVisible(not isOn)
    bugMap.setOn(isOn)
  end)
end

-- ============================================================================
-- 5. SUPORTE, BUFFS & RUNAS
-- ============================================================================

-- Invisibilidade
if claimSharedIcon("invis") then
  addIcon("InvisibleIcon", {item = {id = 2202, count = 1}, text = "Invis"}, macro(5000, function()
    local p = g_game.getLocalPlayer()
    if p and not p:isInvisible() and not isInPz() then
      say("utana vid")
    end
  end))
end

-- Auto Mount
if claimSharedIcon("mount") then
  local mountMacro = macro(3000, function()
    if isInPz() then return end
    local p = g_game.getLocalPlayer()
    if p and not p:isMounted() then
      p:mount()
    end
  end)
  addIcon("Mount", {item = {id = 390, count = 1}, text = "Mount"}, mountMacro)
end

-- Utamo Vita com Renovação Inteligente
if claimSharedIcon("utamo") then
  local utamoDuration = 180
  local renewEarly = 20
  local nextUtamo = 0

  addIcon("renewUtamo", {item = {id = 3548, count = 1}, text = "Utamo"}, macro(500, function()
    local t = millis()
    if not hasManaShield() or t > nextUtamo then
      say("utamo vita")
      nextUtamo = t + ((utamoDuration - renewEarly) * 1000)
      delay(500)
    end
  end))
end

-- Auto Chase Mode (Sem spam)
if claimSharedIcon("chase") then
  addIcon("Chase", {item = {id = 3555, count = 1}, text = "Chase"}, macro(500, function()
    if g_game.getChaseMode() ~= 1 then
      g_game.setChaseMode(1)
    end
  end))
end

-- SD Max, Paralyze Max e Avalanche Max: exclusivos deste pack (não existem
-- no XinaCorePack.lua), então não precisam de trava com ele.
addIcon("SDicon", {item = {id = 3155, count = 1}, text = "SDMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3155, target)
    delay(200)
  end
end))

addIcon("Paraicon", {item = {id = 3165, count = 1}, text = "PARAMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3165, target)
    delay(200)
  end
end))

addIcon("avaicon", {item = {id = 3161, count = 1}, text = "AVAMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3161, target)
    delay(200)
  end
end))
