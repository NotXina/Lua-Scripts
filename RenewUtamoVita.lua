-- ============================================================================
-- RENOVAÇÃO INTELIGENTE DE UTAMO VITA
-- Renova o escudo de mana automaticamente 20s antes de acabar
-- ============================================================================

local utamoDuration = 180 -- Duração total em segundos
local renewEarly = 20     -- Segundos de antecedência para renovar
local nextUtamo = 0

addIcon("renewUtamo", {item = {id = 3548, count = 1}, text = "Utamo"}, macro(500, function()
  local t = now or g_clock.millis()
  if not hasManaShield() or t > nextUtamo then
    say("utamo vita")
    nextUtamo = t + ((utamoDuration - renewEarly) * 1000)
    delay(500)
  end
end))
