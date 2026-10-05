-- ============================================================================
--                   PVP ULTIMATE PACK - OTCV8 / vBOT 4.8
-- ============================================================================

-- ============================================================================
-- ⚙️ CONFIGURAÇÕES GERAIS
-- ============================================================================
local config = {
  -- IDs das Runas
  mwId = 3180,           -- Magic Wall
  wgId = 3156,           -- Wild Growth
  sdId = 3155,           -- Sudden Death (SD)
  destroyFieldId = 3148, -- Destroy Field

  -- IDs de Equipamentos de Defesa
  ssaId = 3081,          -- Stone Skin Amulet
  mightRingId = 3048,    -- Might Ring
  energyRingId = 3051,   -- Energy Ring
  trashId = 3031,        -- Gold Coin para Anti-Push (3031 = Gold, 3035 = Plat)

  -- Limiares de Vida (%)
  ssaHealth = 65,        -- Equipa SSA quando o HP estiver abaixo de 65%
  mightRingHealth = 65,  -- Equipa Might Ring quando o HP estiver abaixo de 65%
  eRingHealth = 40,      -- Equipa Energy Ring quando o HP estiver abaixo de 40%

  -- Paralyze Cure
  paralyzeSpell = "exura", -- Magia para tirar paralyze ("exura", "exura gran", "exura ico")

  -- Suporte de Grupo / Guild
  sioHealth = 70,        -- % de vida do amigo para usar Exura Sio
  leaderName = "Leader Name", -- Nome do Líder de Combo (Altere aqui)

  -- Duração da Magic Wall (ms)
  mwDuration = 20000     -- 20 segundos
}

-- IDs de Field perigosos para Destroy Field
local dangerousFields = {
  [2118] = true, [2119] = true, [2120] = true, -- Fire field
  [2123] = true, [2124] = true, [2125] = true, -- Poison field
  [2126] = true, [2127] = true  -- Energy field
}

-- IDs de Magic Wall no chão
local wallIds = {
  [2128] = true, [2129] = true, [2130] = true, [2131] = true,
  [1497] = true, [1498] = true, [10188] = true, [10189] = true
}

-- Função auxiliar de validação de inimigo
local function isEnemy(creature)
  if not creature or not creature:isPlayer() or creature:isLocalPlayer() then 
    return false 
  end
  local cName = creature:getName():lower()
  local myName = name():lower()
  local shield = creature:getShield() or 0
  local emblem = creature:getEmblem() or 0

  return cName ~= myName and not isFriend(creature:getName()) and shield < 3 and emblem ~= 1
end

-- ============================================================================
-- 1. 🏃 MW SELF STEP (FUGA INTELIGENTE)
-- ============================================================================
local selfStepMacro = macro(10, "MW Self Step", function() end)

onPlayerPositionChange(function(newPos, oldPos)
  if not selfStepMacro.isOn() then return end
  if oldPos and oldPos.z == posz() then
    local tile = g_map.getTile(oldPos)
    if tile and tile:isWalkable() then
      useWith(config.mwId, tile:getTopUseThing() or tile:getGround())
    end
  end
end)

-- ============================================================================
-- 2. 🛡️ ANTI-PUSH INSTANTÂNEO
-- ============================================================================
macro(100, "Anti-Push", function()
  local p = g_game.getLocalPlayer()
  if not p then return end
  local pPos = p:getPosition()
  local tile = g_map.getTile(pPos)
  if not tile then return end

  local topThing = tile:getTopThing()
  if not topThing or topThing:getId() ~= config.trashId then
    local trashItem = findItem(config.trashId)
    if trashItem then
      g_game.move(trashItem, pPos, 1)
    end
  end
end)

-- ============================================================================
-- 3. 💥 AUTO DESTROY FIELD NO PÉ
-- ============================================================================
macro(150, "Auto Destroy Field", function()
  local p = g_game.getLocalPlayer()
  if not p then return end
  local tile = g_map.getTile(p:getPosition())
  if not tile then return end

  for _, item in ipairs(tile:getItems() or {}) do
    if dangerousFields[item:getId()] then
      useWith(config.destroyFieldId, item)
      delay(300)
      return
    end
  end
end)

-- ============================================================================
-- 4. 🌿 AUTO WILD GROWTH NAS DIAGONAIS DO INIMIGO
-- ============================================================================
macro(100, "Trap WG Diagonals", function()
  local target = g_game.getAttackingCreature()
  if not target or not isEnemy(target) then return end
  local tPos = target:getPosition()
  if tPos.z ~= posz() or getDistanceBetween(pos(), tPos) > 6 then return end

  local offsets = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}
  for _, off in ipairs(offsets) do
    local checkPos = {x = tPos.x + off[1], y = tPos.y + off[2], z = tPos.z}
    local tile = g_map.getTile(checkPos)
    if tile and tile:isWalkable() then
      useWith(config.wgId, tile:getTopUseThing() or tile:getGround())
      delay(150)
      return
    end
  end
end)

-- ============================================================================
-- 5. 💍 SMART SSA & MIGHT RING SWAPPER
-- ============================================================================
macro(50, "SSA & Might Swapper", function()
  local hp = hppercent()

  -- SSA
  if hp <= config.ssaHealth then
    local ssa = findItem(config.ssaId)
    local curNeck = getNeck()
    if ssa and (not curNeck or curNeck:getId() ~= config.ssaId) then
      g_game.equipItemId(config.ssaId)
    end
  end

  -- Might Ring
  if hp <= config.mightRingHealth then
    local mRing = findItem(config.mightRingId)
    local curRing = getFinger()
    if mRing and (not curRing or curRing:getId() ~= config.mightRingId) then
      g_game.equipItemId(config.mightRingId)
    end
  end
end)

-- ============================================================================
-- 6. ⚡ SMART ENERGY RING
-- ============================================================================
macro(50, "Smart Energy Ring", function()
  local hp = hppercent()
  local curRing = getFinger()

  if hp <= config.eRingHealth then
    if not curRing or curRing:getId() ~= config.energyRingId then
      g_game.equipItemId(config.energyRingId)
    end
  elseif hp > (config.eRingHealth + 25) then
    if curRing and curRing:getId() == config.energyRingId then
      local backPack = getBack()
      if backPack then
        g_game.move(curRing, backPack:getPosition(), 1)
      end
    end
  end
end)

-- ============================================================
-- 7. 🏃 FAST PARALYZE CURE (ZERO-DELAY)
-- ============================================================
macro(20, "Fast Paralyze Cure", function()
  if isParalyzed() then
    say(config.paralyzeSpell)
    delay(100)
  end
end)

-- ============================================================
-- 8. 🎯 COMBO LEADER (ATACAR COM O LÍDER DA GUILD)
-- ============================================================
macro(50, "Combo Leader", function()
  if config.leaderName == "Leader Name" or config.leaderName == "" then return end
  local pPos = pos()

  for _, spec in ipairs(getSpectators(pPos.z, false)) do
    if spec:getName():lower() == config.leaderName:lower() then
      local leaderTarget = spec:getAttackingCreature()
      if leaderTarget and g_game.getAttackingCreature() ~= leaderTarget then
        g_game.attack(leaderTarget)
      end
      return
    end
  end
end)

-- ============================================================
-- 9. 💥 AUTO SD / RUNA NO TARGET
-- ============================================================
macro(100, "Auto SD Target", function()
  local target = g_game.getAttackingCreature()
  if target and isEnemy(target) then
    local tPos = target:getPosition()
    if tPos.z == posz() and getDistanceBetween(pos(), tPos) <= 7 then
      useWith(config.sdId, target)
      delay(200)
    end
  end
end)

-- ============================================================
-- 10. 💚 AUTO SIO / HEAL AMIGO EM PERIGO
-- ============================================================
macro(150, "Auto Sio Party", function()
  local pPos = pos()
  for _, spec in ipairs(getSpectators(pPos.z, false)) do
    if spec:isPlayer() and not spec:isLocalPlayer() and (spec:getShield() >= 3 or isFriend(spec:getName())) then
      if spec:getHealthPercent() <= config.sioHealth and spec:getHealthPercent() > 0 then
        say("exura sio \"" .. spec:getName())
        delay(400)
        return
      end
    end
  end
end)

-- ============================================================
-- 11. ⏱️ TIMER VISUAL DE MAGIC WALL NO CHÃO
-- ============================================================
local mwMapTimers = {}

macro(50, "Visual MW Timer", function()
  local pPos = pos()
  local t = now or g_clock.millis()

  for _, tile in ipairs(g_map.getTiles(pPos.z)) do
    local posKey = tile:getPosition().x .. "," .. tile:getPosition().y
    local hasMw = false
    
    for _, it in ipairs(tile:getItems() or {}) do
      if wallIds[it:getId()] then
        hasMw = true
        break
      end
    end

    if hasMw then
      if not mwMapTimers[posKey] then
        mwMapTimers[posKey] = t + config.mwDuration
      end
      local remaining = math.max(0, (mwMapTimers[posKey] - t) / 1000)
      tile:setText(string.format("%.1fs", remaining))
    else
      if mwMapTimers[posKey] then
        mwMapTimers[posKey] = nil
        tile:setText("")
      end
    end
  end
end)

-- ============================================================
-- 12. 📊 INIMIGO TARGET HUD
-- ============================================================
local targetLabel = UI.Label()
targetLabel:setPosition({x = 450, y = 30})
targetLabel:setFont("verdana-11px-rounded")
targetLabel:setColor("red")

macro(50, "Target HUD", function()
  local target = g_game.getAttackingCreature()
  if target and isEnemy(target) then
    local hp = target:getHealthPercent()
    local dist = getDistanceBetween(pos(), target:getPosition())
    targetLabel:setText(string.format("ALVO: %s | HP: %d%% | DIST: %d", target:getName(), hp, dist))
    targetLabel:show()
  else
    targetLabel:hide()
  end
end)
