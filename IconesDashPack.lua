-- ============================================================================
--                     ICONES & DASH PACK (OTIMIZADO)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

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

-- ============================================================================
-- 3. ÍCONES CAVEBOT & TARGETBOT (COM INDICADOR ON/OFF LEVE)
-- ============================================================================
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

-- ============================================================================
-- 4. DASH (BUG MAP / MAP CLICK)
-- ============================================================================
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
  local kb = modules.corelib.g_keyboard
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

-- ============================================================================
-- 5. SUPORTE, BUFFS & RUNAS
-- ============================================================================

-- Invisibilidade
addIcon("InvisibleIcon", {item = {id = 2202, count = 1}, text = "Invis"}, macro(5000, function()
  local p = g_game.getLocalPlayer()
  if p and not p:isInvisible() and not isInPz() then
    say("utana vid")
  end
end))

-- Auto Mount
local mountMacro = macro(3000, function()
  if isInPz() then return end
  local p = g_game.getLocalPlayer()
  if p and not p:isMounted() then
    p:mount()
  end
end)
addIcon("Mount", {item = {id = 390, count = 1}, text = "Mount"}, mountMacro)

-- Utamo Vita com Renovação Inteligente
local utamoDuration = 180
local renewEarly = 20
local nextUtamo = 0

addIcon("renewUtamo", {item = {id = 3548, count = 1}, text = "Utamo"}, macro(500, function()
  local t = now or g_clock.millis()
  if not hasManaShield() or t > nextUtamo then
    say("utamo vita")
    nextUtamo = t + ((utamoDuration - renewEarly) * 1000)
    delay(500)
  end
end))

-- Auto Chase Mode (Sem spam)
addIcon("Chase", {item = {id = 3555, count = 1}, text = "Chase"}, macro(500, function()
  if g_game.getChaseMode() ~= 1 then
    g_game.setChaseMode(1)
  end
end))

-- SD Max
addIcon("SDicon", {item = {id = 3155, count = 1}, text = "SDMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3155, target)
    delay(200)
  end
end))

-- Paralyze Max
addIcon("Paraicon", {item = {id = 3165, count = 1}, text = "PARAMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3165, target)
    delay(200)
  end
end))

-- Avalanche Max
addIcon("avaicon", {item = {id = 3161, count = 1}, text = "AVAMAX"}, macro(200, function()
  local target = g_game.getAttackingCreature()
  if target then
    useWith(3161, target)
    delay(200)
  end
end))
