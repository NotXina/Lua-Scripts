-- ============================================================================
-- COMBO ATTACK COM LÍDERES (DETECÇÃO DE MÍSSIL/SD)
-- Ataca automaticamente o mesmo alvo do líder no momento em que sai o míssil
-- ============================================================================

storage.ComboAttack = storage.ComboAttack or {}
local comboSettings = storage.ComboAttack

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

  local leaders = {
    comboSettings.LeaderName:lower(),
    comboSettings.LeaderName2:lower(),
    comboSettings.LeaderName3:lower()
  }

  if table.find(leaders, shooter:getName():lower()) then
    local current = g_game.getAttackingCreature()
    if (not current or current ~= target) and not isFriend(target:getName()) then
      g_game.attack(target)
    end
  end
end)
