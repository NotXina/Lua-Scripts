local tab = addTab("+Xina")
setDefaultTab("+Xina")

warning = function() 
    return  
end

--ICONES
mage_sd= macro(200,function()
    if g_game.isAttacking() then
        usewith(3155, g_game.getAttackingCreature())
    end
end)
addIcon("mage_sd", {item=3155, text="SDMAX"}, function(icon, isOn)
mage_sd.setOn(isOn)
end)

mage_dw = macro(200,function()
    if g_game.isAttacking() then
        usewith(3171, g_game.getAttackingCreature())
    end
end)
addIcon("mage_dw", {item=3171, text="DWMAX"}, function(icon, isOn)
mage_dw.setOn(isOn)
end)

mage_DT = macro(200,function()
    if g_game.isAttacking() then
        usewith(3194, g_game.getAttackingCreature())
    end
end)
addIcon("mage_DT", {item=3194, text="DTMAX"}, function(icon, isOn)
mage_DT.setOn(isOn)
end)


mage_lyze = macro(200,function()
    if g_game.isAttacking() then
        usewith(3165, g_game.getAttackingCreature())
    end
end)
addIcon("mage_lyze", {item=3165, text="PARAMAX"}, function(icon, isOn)
mage_lyze.setOn(isOn)
end)




local wand = 7518 -- wand ID 
local itemsIds = {3554, 3369, 3567, 3420, 3414, 3366, 3364, 3392, 3320, 3281, 7407, 7387, 3079, 826, 10387, 10385, 3006, 3360, 3324, 3381, 3382, 3419, 3385} -- ID items to sell 
Seller = addIcon("Seller", {item = 7518, text = "Seller"},
  macro(100, function()
  for i, itemId in pairs(itemsIds) do
    local item = findItem(itemId)
    if item then
      useWith(wand, item)
      return
    end
  end
end))

Follow = addIcon("Follow", {item=1234, text = "Chase"},
macro(1, "Follow Atk", "Shift+Z", function()
   if g_game.isOnline() and g_game.isAttacking() then
         g_game.setChaseMode(1)
           end
           end))


local cIcon = addIcon("cI",{text="Cave\nBot",switchable=false,moveable=true}, function()
  if CaveBot.isOff() then 
    CaveBot.setOn()
  else 
    CaveBot.setOff()
  end
end)
cIcon:setSize({height=30,width=50})
cIcon.text:setFont('verdana-11px-rounded')

local tIcon = addIcon("tI",{text="Target\nBot",switchable=false,moveable=true}, function()
  if TargetBot.isOff() then 
    TargetBot.setOn()
  else 
    TargetBot.setOff()
  end
end)
tIcon:setSize({height=30,width=50})
tIcon.text:setFont('verdana-11px-rounded')

macro(50,function()
  if CaveBot.isOn() then
    cIcon.text:setColoredText({"CaveBot\n","white","ON","green"})
  else
    cIcon.text:setColoredText({"CaveBot\n","white","OFF","red"})
  end
  if TargetBot.isOn() then
    tIcon.text:setColoredText({"Target\n","white","ON","green"})
  else
    tIcon.text:setColoredText({"Target\n","white","OFF","red"})
  end
end)




-- Fim dos ICONES

UI.Separator()

local name = ""..g_game.getCharacterName()..""
local panelName = "targetLeader"
local toAttack = nil

if not storage[panelName .. name] then
storage[panelName .. name] = {
    attackLeader = "nome do Lider"
}
end

onMissle(function(missle)
    if not storage[panelName .. name].attackLeader or storage[panelName .. name].attackLeader:len() == 0 then
        return
    end
    local src = missle:getSource()
    if src.z ~= posz() then
        return
    end
    local from = g_map.getTile(src)
    local to = g_map.getTile(missle:getDestination())
    if not from or not to then
        return
    end
    local fromCreatures = from:getCreatures()
    local toCreatures = to:getCreatures()
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then
        return
    end
    local c1 = fromCreatures[1]
    if c1:getName():lower() == storage[panelName .. name].attackLeader:lower() then
        toAttack = toCreatures[1]
    end
end)

macro(50, "Attack Leader", nil, function()
    if isInPz() then return end
    if toAttack and storage[panelName .. name].attackLeader:len() > 0 and toAttack ~= g_game.getAttackingCreature() then
        if toAttack:getName() ~= storage[panelName .. name].attackLeader then
            g_game.cancelAttack()
            g_game.attack(toAttack)
            toAttack = nil
        end
    end
end)

	

addTextEdit("attackLeader", storage[panelName .. name].attackLeader or "Nome do Lider", function(widget, lidertext)
    storage[panelName .. name].attackLeader = lidertext
end)

UI.Separator()


UI.Label("Ataca os Players em sua Enemy List")

atack_enemy = macro(100, "Attack Players","Delete", function()
 local highestAmount = 100  
  local targetPlayer
  if isInPz() then return end
  for i, creature in ipairs(getSpectators(posz(), false)) do
    if creature:isPlayer() then
      local cname = creature:getName()
      if isEnemy(cname) then    
        --if creature:getShield() < 3 and creature:getEmblem() ~= 1 then
          local valHp = creature:getHealthPercent()
          if valHp <= highestAmount then
            local cPos = creature:getPosition()
            local cTile = g_map.getTile(cPos)
            if cTile and cTile:canShoot() then
              highestAmount = valHp
              targetPlayer = creature
            end
          end
        end
      end
    end
 -- end
  if targetPlayer then
    if not g_game.isAttacking() or g_game.getAttackingCreature() ~= targetPlayer then
      g_game.attack(targetPlayer)
    end
  end
end)

addIcon("Atk_enemy", {item=5668, text="Kill"}, function(icon, isOn)
atack_enemy.setOn(isOn)
end)



UI.Separator()

UI.Label("Use MW")

local toggle = macro(10, "Mwall Step", "F12",function() end) -- taca mw no sqm anterior

onPlayerPositionChange(function(newPos, oldPos)
    if oldPos.z ~= posz() then return end
    if oldPos then
        local tile = g_map.getTile(oldPos)
        if toggle.isOn() and tile:isWalkable() then
            useWith(3180, tile:getTopUseThing())
            toggle.setOff()
        end
    end
end)

local toggle2 = macro(10, "MW Target Step", "F11", function() end) -- taca mw no sqm onde o alvo esta

onCreaturePositionChange(function(creature, newPos, oldPos)
    if creature == target() or creature == g_game.getFollowingCreature() then
        if oldPos and oldPos.z == posz() then
            local tile2 = g_map.getTile(oldPos)
            if toggle2.isOn() and tile2:isWalkable() then
                useWith(3180, tile2:getTopUseThing())
                toggle2.setOff()
            end 
        end
    end
end)


UI.Separator()

local dropItems = { 3492, 3031 }
local maxStackedItems = 10
local dropDelay = 600

gpAntiPushDrop = macro(dropDelay , "anti push", function ()
  antiPush()
end)

onPlayerPositionChange(function()
    antiPush()
end)

function antiPush()
  if gpAntiPushDrop:isOff() then
    return
  end

  local tile = g_map.getTile(pos())
  if tile and tile:getThingCount() < maxStackedItems then
    local thing = tile:getTopThing()
    if thing and not thing:isNotMoveable() then
      for i, item in pairs(dropItems) do
        if item ~= thing:getId() then
            local dropItem = findItem(item)
            if dropItem then
              g_game.move(dropItem, pos(), 1)
            end
        end
      end
    end
  end
end

local function checkPos(x, y)
 xyz = g_game.getLocalPlayer():getPosition()
 xyz.x = xyz.x + x
 xyz.y = xyz.y + y
 tile = g_map.getTile(xyz)
 if tile then
  return g_game.use(tile:getTopUseThing())  
 else
  return false
 end
end


bugMap = macro(1, function() 
 if modules.corelib.g_keyboard.isKeyPressed('Up') or modules.corelib.g_keyboard.isKeyPressed('w')  then
  checkPos(0, -5)
 elseif modules.corelib.g_keyboard.isKeyPressed('Right') or modules.corelib.g_keyboard.isKeyPressed('d') then
  checkPos(5, 0)
 elseif modules.corelib.g_keyboard.isKeyPressed('Down') or modules.corelib.g_keyboard.isKeyPressed('s') then
  checkPos(0, 5)
 elseif modules.corelib.g_keyboard.isKeyPressed('Left') or modules.corelib.g_keyboard.isKeyPressed('a') then
  checkPos(-5, 0)
 end
 end)
 

bugMapIcon = addIcon("Bug Map", {item=3368, text="DASH", hotkey="NumPad0"}, function(icon, isOn)
  modules.game_console.consoleTextEdit:setVisible(not isOn)
  bugMap.setOn(isOn)
 end)
 
 
 
 
 
 
 
 
 









local toolsTab = addTab("Tools")
local UE = "Magia de Area"

if not storage[UE .. name] then
storage[UE .. name] = {
    AOEspell = "Exevo gran mas pox"
}
end

macro(1000, "Safe SD/Mas Vis", function()
  local target = g_game.getAttackingCreature()
  if not target then return end
  if isSafe(8) and manapercent() >= 70 then
    say(storage[UE .. name].AOEspell)
  else
    usewith(3155, g_game.getAttackingCreature())
  end
end)

addTextEdit("AOEspell", storage[UE .. name].AOEspell or "Exevo gran mas pox", function(widget, uetext)
    storage[UE .. name].AOEspell = uetext
end)



local specName = "alvo"

if not storage[specName .. name] then
storage[specName .. name] = {
    specplayer = "Racumin"
}
end

macro(100, "Atack Fixed Player", function()

if not g_game.isAttacking() or g_game.getAttackingCreature():getName() ~= storage[specName .. name].specplayer then


       for i, spec in ipairs(getSpectators()) do
		local xname = spec:getName()
			 if spec:isPlayer() and spec:getName() == storage[specName .. name].specplayer then
                g_game.attack(spec)
            end
		end
		
end		
		
end) 

addTextEdit("specplayer", storage[specName .. name].specplayer or "alvo", function(widget, alvotext)
    storage[specName .. name].specplayer = alvotext
end)


addSeparator("sep", mainTab)
function comboScript(parent)
  if not parent then
    parent = panel
  end
local panelName = "comboScriptPanel"
 
  local ui = setupUI([[
ThreeRowsItems < Panel
  height: 99
  margin-top: 2
  
  BotItem
    id: item1
    anchors.top: parent.top
    anchors.left: parent.left

  BotItem
    id: item2
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2

  BotItem
    id: item3
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2

  BotItem
    id: item4
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2

  BotItem
    id: item5
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item6
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2

  BotItem
    id: item7
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item8
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item9
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item10
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item11
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 2
    
  BotItem
    id: item12
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item13
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item14
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2
    
  BotItem
    id: item15
    anchors.top: prev.top
    anchors.left: prev.right
    margin-left: 2

Panel
  height: 135

  SmallBotSwitch
    id: title
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  HorizontalScrollBar
    id: scroll1
    anchors.left: title.left
    anchors.right: title.right
    anchors.top: title.bottom
    margin-right: 2
    margin-top: 2
    minimum: 1
    maximum: 60
    step: 1

  ThreeRowsItems
    id: items
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom  
  ]], parent)
  ui:setId(panelName)
 
  if not storage[panelName] then
    storage[panelName] = {
      time = 31
    }
  end
 
  local updateText = function()
    ui.title:setText("Use every " .. storage[panelName].time .. " minutes")  
  end
 
  ui.scroll1.onValueChange = function(scroll, value)
    storage[panelName].time = value
    updateText()
  end
 
  ui.scroll1:setValue(storage[panelName].time)
 
  ui.title:setOn(storage[panelName].enabled)
  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end
 
  if type(storage[panelName].items) ~= 'table' then
    storage[panelName].items = { 3215, 9642, 3726, 11454, 945, 10293, 10306, 10316, 11455 }
  end
 
  for i=1,15 do
    ui.items:getChildByIndex(i).onItemChange = function(widget)
      storage[panelName].items[i] = widget:getItemId()
    end
    ui.items:getChildByIndex(i):setItemId(storage[panelName].items[i])    
  end
 
  macro(1000, function()
    if not storage[panelName].enabled then
      return
    end

    if #storage[panelName].items > 0 then
      timeOut = 5000
      for _, itemToUse in pairs(storage[panelName].items) do
        schedule(timeOut, function()
          use(itemToUse)
        end)
        timeOut = timeOut + 500
      end
    end
    schedule(timeOut + 5000, function()
    end)
    delay((storage[panelName].time * 60000) - 1000)
  end)
end
comboScript(mainTab)
addSeparator("sep", mainTab)




