-- ============================================================================
-- ANTI-PUSH INSTANTÂNEO (COM MOEDAS)
-- Joga moedas debaixo do seu pé sem parar para impedir que te empurrem
-- ============================================================================

local trashId = 3031 -- 3031 = Gold Coin | 3035 = Platinum Coin

macro(100, "Anti-Push", function()
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then return end
  
  local pPos = localPlayer:getPosition()
  local tile = g_map.getTile(pPos)
  if not tile then return end

  local top = tile:getTopThing()
  if not top or top:getId() ~= trashId then
    local item = findItem(trashId)
    if item then
      g_game.move(item, pPos, 1)
    end
  end
end)
