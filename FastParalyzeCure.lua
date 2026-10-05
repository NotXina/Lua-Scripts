-- ============================================================================
-- FAST PARALYZE CURE (ZERO-DELAY)
-- Cura o Paralyze com magia no exato milissegundo em que for paralisado
-- ============================================================================

local cureSpell = "exura" -- "exura", "exura gran" ou "exura ico"

macro(20, "Fast Paralyze Cure", function()
  if isParalyzed() then
    say(cureSpell)
    delay(100)
  end
end)
