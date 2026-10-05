-- ============================================================================
-- UH NO TIME (CURA AMIGO COM MENOR HP)
-- Foca a runa de UH no membro da party/guild mais ferido
-- ============================================================================

macro(500, "UH NO TIME", function()
  if hppercent() <= 90 then return end

  local lowestFriend = nil
  local lowestHp = 91

  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName()) then
        local hp = spec:getHealthPercent()
        if hp < lowestHp and hp > 0 then
          lowestHp = hp
          lowestFriend = spec
        end
      end
    end
  end

  if lowestFriend then
    useWith(3160, lowestFriend)
    delay(400)
  end
end)
