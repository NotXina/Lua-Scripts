-- ============================================================================
-- SMART SSA & MIGHT RING SWAPPER
-- Equipa Stone Skin Amulet e Might Ring em situações de emergência de HP
-- ============================================================================

local ssaId = 3081        -- ID do SSA
local mightRingId = 3048  -- ID do Might Ring
local minHp = 65          -- % de vida para equipar

macro(50, "SSA & Might Swapper", function()
  local hp = hppercent()

  if hp <= minHp then
    -- Equipa SSA
    local ssa = findItem(ssaId)
    local curNeck = getNeck()
    if ssa and (not curNeck or curNeck:getId() ~= ssaId) then
      g_game.equipItemId(ssaId)
    end

    -- Equipa Might Ring
    local mRing = findItem(mightRingId)
    local curRing = getFinger()
    if mRing and (not curRing or curRing:getId() ~= mightRingId) then
      g_game.equipItemId(mightRingId)
    end
  end
end)
