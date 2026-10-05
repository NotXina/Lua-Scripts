-- ============================================================================
-- AUTO SIO / HEAL PARTY EM PERIGO
-- Cura os membros da party automaticamente com Exura Sio
-- ============================================================================

local minFriendHp = 70 -- % de vida para dar Sio

macro(150, "Auto Sio Party", function()
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() and (spec:getShield() >= 3 or isFriend(spec:getName())) then
      if spec:getHealthPercent() <= minFriendHp and spec:getHealthPercent() > 0 then
        say("exura sio \"" .. spec:getName())
        delay(400)
        return
      end
    end
  end
end)
