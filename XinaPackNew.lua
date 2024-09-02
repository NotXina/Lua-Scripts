local tab = addTab("+Xina")
setDefaultTab("+Xina")
warning = function() 
    return  
end

--ICONES
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    font: verdana-11px-rounded
    !text: tr('Runa')

  Button
    id: edit
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded
]])

local edit = setupUI([[
RevideBox < CheckBox
  font: verdana-11px-rounded
  margin-top: 5
  margin-left: 5
  anchors.top: prev.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  color: lightGray

Panel
  height: 60

  BotItem
    id: defaultLeftItem
    anchors.left: parent.left
    anchors.top: parent.top
    margin-left: 5
    margin-top: 17

]])
edit:hide()

local showEdit = false
ui.edit.onClick = function(widget)
    showEdit = not showEdit
    if showEdit then
        edit:show()
    else
        edit:hide()
    end
end

-- Storage
local st = "Rune"
storage[st] = storage[st] or {
    enabled = false,
    defaultLeftItemId = 1,
}
local config = storage[st]

-- UI Functions
-- Main Button
ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setOn(config.enabled)
end


do
    edit.defaultLeftItem:setItemId(config.defaultLeftItemId)
    edit.defaultLeftItem.onItemChange = function(self)
        config.defaultLeftItemId = self:getItemId()
    end
end




macro(100, function()
  local target = g_game.getAttackingCreature()
  if not storage[st].enabled then return; end
  if not g_game.isAttacking() then return; end
  if not target:canShoot() then return; end
  useWith(config.defaultLeftItemId, target)
  delay(500)
end)

Pally_PvP= macro(500, function()
  if g_game.isAttacking() then
  say("exori gran con")   
  end
end)

addIcon("(RP) PvP", {item=25757, text="(RP) PvP"}, function(icon, isOn)
Pally_PvP.setOn(isOn)
end)

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
 
 
 

-- Fim dos ICONES

 local panelName = "advancedFriendHealer"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Friend Healer')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
      
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      minMana = 60,
      minFriendHp = 40,
      customSpellName = "exura max sio",
      customSpell = false,
      distance = 8,
      itemHeal = false,
      id = 3160,
      exuraSio = false,
      exuraGranSio = false,
      exuraMasRes = false,
      healEk = false,
      healRp = false,
      healEd = false,
      healMs = false
    }
  end

  local config = storage[panelName]

  -- basic elements
  ui.title:setOn(config.enabled)
  ui.title.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setOn(config.enabled)
  end
  ui.editList.onClick = function(widget)
    sioListWindow:show()
    sioListWindow:raise()
    sioListWindow:focus()
  end

  rootWidget = g_ui.getRootWidget()
  if rootWidget then
    sioListWindow = UI.createWindow('SioListWindow', rootWidget)
    sioListWindow:hide()

    -- TextWindow
    sioListWindow.spellName:setText(config.customSpellName)
    sioListWindow.spellName.onTextChange = function(widget, text)
      config.customSpellName = text
    end

    -- botswitches
    sioListWindow.spell:setOn(config.customSpell)
    sioListWindow.spell.onClick = function(widget)
      config.customSpell = not config.customSpell
      widget:setOn(config.customSpell)
    end
    sioListWindow.item:setOn(config.itemHeal)  
    sioListWindow.item.onClick = function(widget)
      config.itemHeal = not config.itemHeal
      widget:setOn(config.itemHeal)
    end
    sioListWindow.exuraSio:setOn(config.exuraSio)  
    sioListWindow.exuraSio.onClick = function(widget)
      config.exuraSio = not config.exuraSio
      widget:setOn(config.exuraSio)
    end 
    sioListWindow.exuraGranSio:setOn(config.exuraGranSio)  
    sioListWindow.exuraGranSio.onClick = function(widget)
      config.exuraGranSio = not config.exuraGranSio
      widget:setOn(config.exuraGranSio)
    end
    sioListWindow.exuraMasRes:setOn(config.exuraMasRes)  
    sioListWindow.exuraMasRes.onClick = function(widget)
      config.exuraMasRes = not config.exuraMasRes
      widget:setOn(config.exuraMasRes)
    end
    sioListWindow.vocation.ED:setOn(config.healEd)  
    sioListWindow.vocation.ED.onClick = function(widget)
      config.healEd = not config.healEd
      widget:setOn(config.healEd)
    end
    sioListWindow.vocation.MS:setOn(config.healMs)  
    sioListWindow.vocation.MS.onClick = function(widget)
      config.healMs = not config.healMs
      widget:setOn(config.healMs)
    end
    sioListWindow.vocation.EK:setOn(config.healEk)  
    sioListWindow.vocation.EK.onClick = function(widget)
      config.healEk = not config.healEk
      widget:setOn(config.healEk)
    end
    sioListWindow.vocation.RP:setOn(config.healRp)  
    sioListWindow.vocation.RP.onClick = function(widget)
      config.healRp = not config.healRp
      widget:setOn(config.healRp)
    end

    -- functions
    local updateMinManaText = function()
      sioListWindow.manaInfo:setText("Minimum Mana >= " .. config.minMana .. "%")
    end
    local updateFriendHpText = function()
      sioListWindow.friendHp:setText("Heal Friend Below " .. config.minFriendHp .. "% hp")  
    end
    local updateDistanceText = function()
      sioListWindow.distText:setText("Max Distance: " .. config.distance)
    end

    -- scrollbars and text updates
    sioListWindow.Distance:setValue(config.distance)
    sioListWindow.Distance.onValueChange = function(scroll, value)
      config.distance = value
      updateDistanceText()
    end
    updateDistanceText()

    sioListWindow.minMana:setValue(config.minMana)
    sioListWindow.minMana.onValueChange = function(scroll, value)
      config.minMana = value
      updateMinManaText()
    end
    updateMinManaText()

    sioListWindow.minFriendHp:setValue(config.minFriendHp)
    sioListWindow.minFriendHp.onValueChange = function(scroll, value)
      config.minFriendHp = value
      updateFriendHpText()
    end
    updateFriendHpText()

    sioListWindow.itemId:setItemId(config.id)
    sioListWindow.itemId.onItemChange = function(widget)
      config.id = widget:getItemId()
    end

    sioListWindow.closeButton.onClick = function(widget)
      sioListWindow:hide()
    end

  end

  -- local variables
  local newTibia = g_game.getClientVersion() >= 960

  local function isValid(name)
    if not newTibia then return true end

    local voc = vBot.BotServerMembers[name]
    if not voc then return true end
    
    if voc == 11 then voc = 1
    elseif voc == 12 then voc = 2
    elseif voc == 13 then voc = 3
    elseif voc == 14 then voc = 4
    end

    local isOk = false
    if voc == 1 and config.healEk then
      isOk = true
    elseif voc == 2 and config.healRp then
      isOk = true
    elseif voc == 3 and config.healMs then
      isOk = true
    elseif voc == 4 and config.healEd then
      isOk = true
    end

    return isOk
  end

  macro(200, function()
    if not config.enabled then return end
    if modules.game_cooldown.isGroupCooldownIconActive(2) then return end

    --[[
      1. custom spell
      2. exura gran sio - at 50% of minHpValue
      3. exura gran mas res
      4. exura sio
      5. item healing
    --]]

    -- exura gran sio & custom spell
    if config.customSpell or config.exuraGranSio then
      for i, spec in ipairs(getSpectators()) do
        if spec:isPlayer() and spec ~= player and isValid(spec:getName()) and spec:canShoot() then
          if isFriend(spec) then
            if config.customSpell and spec:getHealthPercent() <= config.minFriendHp then
              return cast(config.customSpellName .. ' "' .. spec:getName() .. '"', 1000)
            end
            if config.exuraGranSio and spec:getHealthPercent() <= config.minFriendHp/3 then
              if canCast('exura gran sio "' .. spec:getName() ..'"') then
                return cast('exura gran sio "' .. spec:getName() ..'"', 60000)
              end
            end
          end
        end
      end
    end

    -- exura gran mas res and standard sio
    local friends = 0
    if config.exuraMasRes then
      for i, spec in ipairs(getSpectators(player, largeRuneArea)) do
        if spec:isPlayer() and spec ~= player and isValid(spec:getName()) and spec:canShoot() then
          if isFriend(spec) and spec:getHealthPercent() <= config.minFriendHp then
            friends = friends + 1
          end
        end
      end
      if friends > 1 then
        return cast('exura gran mas res', 2000)
      end
    end
    if config.exuraSio or config.itemHeal then
      for i, spec in ipairs(getSpectators()) do
        if spec:isPlayer() and spec ~= player and isValid(spec:getName()) and spec:canShoot() then
          if isFriend(spec) then
            if spec:getHealthPercent() <= config.minFriendHp then
              if config.exuraSio then
                return cast('exura sio "' .. spec:getName() .. '"', 1000)
              elseif findItem(config.id) and distanceFromPlayer(spec:getPosition()) <= config.distance then
                return useWith(config.id, spec)
              end
            end
          end
        end
      end
    end 

  end)
addSeparator()




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
macro(50, "Trapa Alvo MW", function()
function lanca(x,y)
	local target = g_game.getAttackingCreature()
	local tpos = target:getPosition()
	local pos = {x=tpos.x + x, y=tpos.y + y, z=tpos.z}
	local tile = g_map.getTile(pos)   
	if tile and tile:isWalkable(false) then -- if can throw magic wall
		usewith(3180, tile:getGround()) -- use wild growth, magic wall is 3180
	return true
	end
	return false
  end

local attacking = g_game.getAttackingCreature()
	if attacking then
		local target = g_game.getAttackingCreature()
		local tpos = target:getPosition()
		xx = posx()-tpos.x
		yy = posy()-tpos.y
		info("xx: ".. xx .. " yy: " .. yy)
		if yy > 0 then
			lanca(0, -1)
			lanca(-1, -1)
			lanca(1, -1)
		end
		if xx > 0 then
			lanca(-1, -1)
			lanca(-1, 0)
			lanca(-1, 1)
		end
		if yy < 0 then
			lanca(-1,1)
			lanca(0,1)
			lanca(1,1)
		end
		if xx < 0 then
			lanca(1, -1)
			lanca(1, 0)
			lanca(1, 1)
		end	
	end
end
)



UI.Separator()

if not storage["antipushAnen"] then
  storage["antipushAnen"] = {
    enabled = false,
    trash ={},
    proximity = {
      enabled = false,
      value = 2
    }
  }
end
local config = storage["antipushAnen"]
local s = {}

g_ui.loadUIFromString([[
antiPushAnenWindow < MainWindow
  size: 400 400
  $mobile:
    size: 320 150
  !text: tr('Anti Push Anen')
  @onEnter: self:hide()
  @onEscape: self:hide()
  padding: 25 8 8 8

  Button
    id: btnClose
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    text: Close
    width: 50
    @onClick: self:getParent():hide()
    
  BotContainer
    id: container
    anchors.fill: parent
    anchors.bottom: parent.verticalCenter
    anchors.right: parent.horizontalCenter
    
  CheckBox
    id: proximity
    text: Proximity
    anchors.top: parent.top
    anchors.left: parent.horizontalCenter
    width: 95
    margin-left: 10

  SpinBox
    id: value
    anchors.top: prev.bottom
    anchors.left: parent.horizontalCenter
    margin-left: 10
    margin-top: 5
    maximum: 8
    minimum: 1
    
  Button
    id: generateIcon
    text: Generate Icon
    anchors.top: prev.bottom
    anchors.left: prev.left
    margin-top: 8
]])

local parent = UI.createWindow("antiPushAnenWindow", g_ui.getRootWidget())
parent:hide()

UI.Container(function(widget)
    config.trash = parent.container:getItems()
end, true, nil, parent.container) 
parent.container:setItems(config.trash)

parent.proximity:setChecked(config.proximity.enabled)
parent.proximity.onCheckChange = function(w, isOn)
  config.proximity.enabled = isOn
end

parent.value:setValue(config.proximity.value)
parent.value.onValueChange = function(wi, value)
  config.proximity.value = value
end



parent.generateIcon.onClick = function()
  CHECKER_ICON({ type = "bot", name =  "Anti Push", switch = true, nameIcon = "Anti Push"})
end


UI.SwitchAndButton({on = config.enabled, left = "Anti Push", right =
"setup"}, function()
  config.enabled = not config.enabled
  s.macro.setOn(config.enabled)
end, function()
  parent:show()
  parent:focus()
end)

function distanceFromPlayer(coords)
    if not coords then return false end
    return getDistanceBetween(pos(), coords)
end

function getPlayers(range, multifloor)
    if not range then range = 10 end
    local specs = 0;
    for _, spec in pairs(getSpectators(multifloor)) do
        if not spec:isLocalPlayer() and spec:isPlayer() and distanceFromPlayer(spec:getPosition()) <= range and not ((spec:getShield() ~= 1 and spec:isPartyMember()) or spec:getEmblem() == 1) then
            specs = specs + 1
        end
    end
    return specs;
end

s.macro = macro(100, "AntiPushAnen", function ()
  if config.proximity.enabled and getPlayers(config.proximity.value, false) <= 0 then return end
  
  local tile = g_map.getTile(pos())
  if #tile:getItems() <= 1 or (#tile:getItems() > 1 and not tile:getItems()[2]:isPickupable()) then
      for _, item in ipairs(config.trash) do
          schedule(_ * 30, function ()
              g_game.move(findItem(item.id), pos(), math.random(1,2))
          end)
      end
  end
end)
s.macro.switch:setVisible(false)
s.macro.setOn(config.enabled)


UI.Separator()


function staminaItems(parent)
  if not parent then
    parent = panel
  end
  local panelName = "staminaItemsUser"
  local ui = setupUI([[
Panel
  height: 65
  margin-top: 2

  SmallBotSwitch
    id: title
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  HorizontalScrollBar
    id: scroll1
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: title.bottom
    margin-right: 2
    margin-top: 2
    minimum: 0
    maximum: 42
    step: 1
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.top
    margin-left: 2
    minimum: 0
    maximum: 42
    step: 1    

  ItemsRow
    id: items
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      min = 0,
      max = 40,
    }
  end

  local updateText = function()
    ui.title:setText("" .. storage[panelName].min .. " <= Stamina >= " .. storage[panelName].max .. "")  
  end
 
  ui.scroll1.onValueChange = function(scroll, value)
    storage[panelName].min = value
    updateText()
  end
  ui.scroll2.onValueChange = function(scroll, value)
    storage[panelName].max = value
    updateText()
  end
 
  ui.scroll1:setValue(storage[panelName].min)
  ui.scroll2:setValue(storage[panelName].max)
 
  ui.title:setOn(storage[panelName].enabled)
  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end
 
  if type(storage[panelName].items) ~= 'table' then
    storage[panelName].items = { 11588 }
  end
 
  for i=1,5 do
    ui.items:getChildByIndex(i).onItemChange = function(widget)
      storage[panelName].items[i] = widget:getItemId()
    end
    ui.items:getChildByIndex(i):setItemId(storage[panelName].items[i])    
  end
 
  macro(500, function()
    if not storage[panelName].enabled or stamina() / 60 < storage[panelName].min or stamina() / 60 > storage[panelName].max then
      return
    end
    local candidates = {}
    for i, item in pairs(storage[panelName].items) do
      if item >= 100 then
        table.insert(candidates, item)
      end
    end
    if #candidates == 0 then
      return
    end    
    use(candidates[math.random(1, #candidates)])
  end)
end
staminaItems()

addSeparator()
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
comboScript()
addSeparator()

macro(200, "Potar Amigo", function()
  for _, creature in pairs(getSpectators(posz())) do
  local heal_player = creature:getName();
  if (heal_player == storage.Friend) then
  if isInPz() then
    useWith(tonumber(storage.Pot), creature)
  end
  end
  end
end)

addLabel("name", "Nome do Amigo:")
addTextEdit("friend", storage.Friend or "", function(widget, text)    
  storage.Friend = text
end) 

addLabel("name", "ID POT:")
addTextEdit("pot", storage.Pot or "", function(widget, text)    
  storage.Pot = text
end) 
addSeparator()


