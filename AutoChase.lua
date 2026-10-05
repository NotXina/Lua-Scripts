-- ============================================================================
-- AUTO CHASE MODE (SEM SPAM DE PACOTES)
-- Mantém o modo Chase ativo sem sobrecarregar a conexão
-- ============================================================================

addIcon("Chase", {item = {id = 3555, count = 1}, text = "Chase"}, macro(500, function()
  if g_game.getChaseMode() ~= 1 then
    g_game.setChaseMode(1)
  end
end))
