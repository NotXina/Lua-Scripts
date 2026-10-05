-- ============================================================================
-- ATTACK PLAYERS (FOCA NO INIMIGO COM MENOR HP & MENOR DISTÂNCIA)
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
