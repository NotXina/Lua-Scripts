-- ============================================================================
-- AUTO INVISIBLE (UTANA VID)
-- Mantém a invisibilidade ativa automaticamente fora do PZ
-- ============================================================================

addIcon("InvisibleIcon", {item = {id = 2202, count = 1}, text = "Invis"}, macro(5000, function()
  local p = g_game.getLocalPlayer()
  if p and not p:isInvisible() and not isInPz() then
    say("utana vid")
  end
end))
