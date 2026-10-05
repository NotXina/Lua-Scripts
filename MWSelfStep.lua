-- ============================================================================
-- MW SELF STEP (FUGA INTELIGENTE)
-- Joga MW no SQM de onde você acabou de sair para trapar quem te persegue
-- ============================================================================

local mwId = 3180 -- ID da Magic Wall (use 2293 para 7.4/8.0)

local selfStep = macro(10, "MW Self Step", function() end)

onPlayerPositionChange(function(newPos, oldPos)
  if not selfStep.isOn() then return end
  if oldPos and oldPos.z == posz() then
    local tile = g_map.getTile(oldPos)
    if tile and tile:isWalkable() then
      useWith(mwId, tile:getTopUseThing() or tile:getGround())
    end
  end
end)
