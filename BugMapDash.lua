-- ============================================================================
-- BUG MAP DASH (MOVIMENTAÇÃO ULTRA RÁPIDA PELO TECLADO)
-- Permite dar dash no mapa segurando W, A, S, D ou as Setas
-- ============================================================================

local function checkPos(offX, offY)
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then return end
  local pPos = localPlayer:getPosition()
  
  local targetPos = {x = pPos.x + offX, y = pPos.y + offY, z = pPos.z}
  local tile = g_map.getTile(targetPos)
  if tile then
    local top = tile:getTopUseThing()
    if top then
      g_game.use(top)
    end
  end
end

local bugMap = macro(25, function()
  -- g_keyboard é global do OTClientV8 (corelib/keyboard.lua) e já é exposto
  -- no contexto do bot. "modules.corelib.g_keyboard" é nil e quebra o macro.
  local kb = g_keyboard
  if kb.isKeyPressed('Up') or kb.isKeyPressed('w') then
    checkPos(0, -5)
  elseif kb.isKeyPressed('Right') or kb.isKeyPressed('d') then
    checkPos(5, 0)
  elseif kb.isKeyPressed('Down') or kb.isKeyPressed('s') then
    checkPos(0, 5)
  elseif kb.isKeyPressed('Left') or kb.isKeyPressed('a') then
    checkPos(-5, 0)
  end
end)
bugMap.setOff()

addIcon("Bug Map", {item = 3368, text = "DASH", hotkey = "NumPad0"}, function(icon, isOn)
  modules.game_console.consoleTextEdit:setVisible(not isOn)
  bugMap.setOn(isOn)
end)
