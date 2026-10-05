-- ============================================================================
--                   PUSHMAX ICONS (DIREÇÕES 1 A 9 - ZERO LAG)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

setDefaultTab("main")

local fireFieldId = 3188 -- ID da Runa de Fire Field (ou Destroy Field)

-- Mapeamento das 8 direções com suporte ao NumPad e Teclado Comum
local iconsData = {
  {imgId = 2572, name = "NW", numKey = "7", numpad = "NumPad7", x = -1, y = -1},
  {imgId = 2573, name = "N",  numKey = "8", numpad = "NumPad8", x =  0, y = -1},
  {imgId = 2574, name = "NE", numKey = "9", numpad = "NumPad9", x =  1, y = -1},
  {imgId = 2575, name = "W",  numKey = "4", numpad = "NumPad4", x = -1, y =  0},
  {imgId = 2577, name = "E",  numKey = "6", numpad = "NumPad6", x =  1, y =  0},
  {imgId = 2578, name = "SW", numKey = "1", numpad = "NumPad1", x = -1, y =  1},
  {imgId = 2579, name = "S",  numKey = "2", numpad = "NumPad2", x =  0, y =  1},
  {imgId = 2580, name = "SE", numKey = "3", numpad = "NumPad3", x =  1, y =  1}
}

-- Função que executa o empurrão do alvo na direção indicada
local function pushTargetInDirection(dirX, dirY)
  local target = g_game.getAttackingCreature() or g_game.getFollowingCreature()
  if not target then return end

  local myPos = pos()
  local targetPos = target:getPosition()
  if not targetPos or targetPos.z ~= myPos.z or getDistanceBetween(myPos, targetPos) > 7 then
    return
  end

  local pushTo = {x = targetPos.x + dirX, y = targetPos.y + dirY, z = targetPos.z}
  local pushToTile = g_map.getTile(pushTo)
  if not pushToTile or not pushToTile:isWalkable() or #pushToTile:getCreatures() > 0 then
    return
  end

  local targetTile = g_map.getTile(targetPos)
  if targetTile then
    local topThing = targetTile:getTopUseThing()
    if topThing and (topThing:isPickupable() or not topThing:isNotMoveable()) then
      useWith(fireFieldId, target)
    end
  end

  g_game.move(target, pushTo)
end

-- Registra os Ícones na tela
for i, data in ipairs(iconsData) do
  addIcon("Push_" .. data.name, {item = {id = data.imgId, count = 1}, text = data.name, hotkey = data.numKey}, function()
    pushTargetInDirection(data.x, data.y)
  end)
end

-- Suporte extra para quem usa o Teclado Numérico (NumPad 1 a 9)
onKeyDown(function(keys)
  for _, data in ipairs(iconsData) do
    if keys == data.numpad or keys == data.numKey then
      pushTargetInDirection(data.x, data.y)
      return
    end
  end
end)
