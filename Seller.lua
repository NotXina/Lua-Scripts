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

local getContainerItemsIds = function(data)
  local idsTable = {}
  local data = data or {}
  for _, item in ipairs(data) do
    if type(item) ~= "number" then
      table.insert(idsTable, item.id)
    elseif type(item) == "number" then
      table.insert(idsTable, item)
    end
  end
  return idsTable
end

local sellMacro = macro(50, function()
  local containers = getContainers()
  for i, container in pairs(containers) do
    for j, item in ipairs(container:getItems()) do
      if table.find(getContainerItemsIds(storage.ItemsToSell), item:getId()) then
        useWith(sellWand, item)
        return delay(250)
      end
    end
  end
end)

addIcon("SellIcon", {item={id=sellWand, count=1}, text= "Sell"}, sellMacro)
