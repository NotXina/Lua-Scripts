-- ============================================================================
-- AUTO MOUNT (MONTARIA AUTOMÁTICA)
-- Monta automaticamente sempre que sair de zonas protegidas (PZ)
-- ============================================================================

local mountMacro = macro(3000, function()
  if isInPz() then return end
  local p = g_game.getLocalPlayer()
  if p and not p:isMounted() then
    p:mount()
  end
end)

addIcon("Mount", {item = {id = 390, count = 1}, text = "Mount"}, mountMacro)
