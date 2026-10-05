-- ============================================================================
-- AUTO MW NO STEP DO INIMIGO
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

local mwId = 3180 -- ID da runa de Magic Wall (se for versão 7.4/8.0 mude para 2293)

local mwStep = macro(10, "MW Enemy Step", function() end)

-- Validação de inimigo sem checagem de HP (Foco em Shield e Guild)
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

-- Dispara instantaneamente no frame em que a criatura se move
onCreaturePositionChange(function(creature, newPos, oldPos)
  if not mwStep.isOn() then return end

  if isValidEnemy(creature) then
    local localPlayer = g_game.getLocalPlayer()
    if not localPlayer then return end
    local myPosition = localPlayer:getPosition()

    -- Se o inimigo andou no mesmo andar e a até 7 SQMs de você
    if oldPos and oldPos.z == myPosition.z and getDistanceBetween(myPosition, oldPos) <= 7 then
      local tile = g_map.getTile(oldPos)
      if tile and tile:isWalkable() then
        local target = tile:getTopUseThing() or tile:getGround()
        if target then
          useWith(mwId, target)
        end
      end
    end
  end
end)
