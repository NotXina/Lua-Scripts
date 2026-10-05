local sellWand = 651

if type(storage.ItemsToSell) ~= "table" then
  storage.ItemsToSell = {822, 7412, 7388, 3554, 7423, 7422, 32208, 32209, 8074, 821, 823, 32187, 32188, 16126, 3364, 3281, 3366, 7422, 7423, 3071, 3280, 3420, 3079, 3392, 7402, 3386, 32188, 32185, 32187, 32186, 3360, 3342, 3370, 7430, 3281, 8057, 3414, 32180, 32179, 32178, 3063, 826, 7382, 41971, 41968, 41969, 41970, 41966, 41965, 41967}
end

addSeparator()
addLabel("","Items To Sell")
addSeparator()
local ItemsToSellContainer = UI.Container(function(widget, items)
  storage.ItemsToSell = items
end, true)
addSeparator()
ItemsToSellContainer:setHeight(90)
ItemsToSellContainer:setItems(storage.ItemsToSell)

-- Monta um mapa id -> true para busca O(1).
local getContainerItemsIds = function(data)
  local idsTable = {}
  for _, item in ipairs(data or {}) do
    local id = type(item) == "number" and item or item.id
    if type(id) == "number" and id > 0 then
      idsTable[id] = true
    end
  end
  return idsTable
end

local sellMacro = macro(50, function()
  -- A lista era reconstruída para CADA item de CADA container, a cada 50ms
  -- (dezenas de tabelas novas por tick). Agora é montada uma vez por execução.
  local sellIds = getContainerItemsIds(storage.ItemsToSell)

  local containers = getContainers()
  for i, container in pairs(containers) do
    for j, item in ipairs(container:getItems()) do
      if sellIds[item:getId()] then
        useWith(sellWand, item)
        return delay(250)
      end
    end
  end
end)

addIcon("SellIcon", {item={id=sellWand, count=1}, text= "Sell"}, sellMacro)
