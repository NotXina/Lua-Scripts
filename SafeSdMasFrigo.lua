-- ============================================================================
-- SAFE SD / UE
-- Alterna entre UE (se for seguro sem atingir amigos) e SD no alvo
-- ============================================================================

storage.safeSdMasFrigo = storage.safeSdMasFrigo or {}
local safeSettings = storage.safeSdMasFrigo

addLabel("", "Magia no modo seguro (UE):"):setColor("orange")
addTextEdit("TxtEditSpell", safeSettings.Spell or "exevo gran mas frigo", function(widget, text)
  safeSettings.Spell = text
end)

macro(1000, "Safe SD/UE", function()
  local target = g_game.getAttackingCreature()
  if not target then return end

  if isSafe(8) and getDistanceBetween(pos(), target:getPosition()) <= 4 then
    local spell = safeSettings.Spell
    if spell and spell:match("%S") then
      say(spell)
    end
  else
    useWith(3155, target)
  end
end)
