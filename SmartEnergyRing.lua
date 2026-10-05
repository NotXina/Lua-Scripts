-- ============================================================================
-- SMART ENERGY RING (UTAMO POR ANEL)
-- Coloca o Energy Ring em emergências e desequipa ao recuperar a vida
-- ============================================================================

local energyRingId = 3051 -- ID do Energy Ring
local equipHp = 40        -- Equipa com menos de 40% de HP
local unequipHp = 70      -- Tira quando passar de 70% de HP

macro(50, "Smart Energy Ring", function()
  local hp = hppercent()
  local curRing = getFinger()

  if hp <= equipHp then
    if not curRing or curRing:getId() ~= energyRingId then
      g_game.equipItemId(energyRingId)
    end
  elseif hp >= unequipHp then
    if curRing and curRing:getId() == energyRingId then
      local bp = getBack()
      if bp then
        g_game.move(curRing, bp:getPosition(), 1)
      end
    end
  end
end)
