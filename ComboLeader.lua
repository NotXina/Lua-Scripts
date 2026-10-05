-- ============================================================================
-- COMBO LEADER (ATAQUE SINCRONIZADO DE GUILD)
-- Ataca automaticamente o mesmo inimigo que o líder da sua guild atacar
-- ============================================================================

local leaderName = "Nome Do Lider" -- Altere para o nick do líder da sua guild

macro(50, "Combo Leader", function()
  if leaderName == "Nome Do Lider" or leaderName == "" then return end
  
  for _, spec in ipairs(getSpectators(posz(), false)) do
    if spec:getName():lower() == leaderName:lower() then
      local leaderTarget = spec:getAttackingCreature()
      if leaderTarget and g_game.getAttackingCreature() ~= leaderTarget then
        g_game.attack(leaderTarget)
      end
      return
    end
  end
end)
