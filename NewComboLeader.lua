-- ============================================================================
-- NEW COMBO LEADER
-- Combo de até 3 líderes por míssil, com runa (SD) ou magia configurável.
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

if not storage.NewComboLeader then
  storage.NewComboLeader = {}
end

local settings = storage.NewComboLeader

-- Defaults
if settings.enabled == nil then settings.enabled = true end
if not settings.sdMissle then settings.sdMissle = 32 end
if not settings.AttackEnemiesHK then settings.AttackEnemiesHK = "f5" end

settings.LeaderName1 = settings.LeaderName1 or "leader1"
settings.LeaderName2 = settings.LeaderName2 or "leader2"
settings.LeaderName3 = settings.LeaderName3 or "leader3"

-- UE triggered by the leader's chat message.
settings.LeaderSpell = settings.LeaderSpell or "exevo gran mas frigo"
settings.UE = settings.UE or "exevo gran mas frigo"

-- Combo triggered by the configured missile. Set Combo Mode to Spell to use it.
-- An empty value is intentional: the player must choose a spell valid on the server.
if settings.ComboSpell == nil then settings.ComboSpell = "" end
if settings.comboMode ~= "spell" and settings.comboMode ~= "rune" then
  settings.comboMode = "rune"
end

-- Priority lock for the current leader (1, 2, 3) or nil.
settings.leaderLock = settings.leaderLock or nil

g_ui.loadUIFromString([[
NewComboLeaderTextEdit < Panel
  height: 40

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  TextEdit
    id: textEdit
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 10
    step: 1
    text-align: center

NewComboLeaderItem < Panel
  height: 34
  margin-top: 7
  margin-left: 25
  margin-right: 25

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.verticalCenter: next.verticalCenter

  BotItem
    id: item
    anchors.top: parent.top
    anchors.right: parent.right

NewComboLeaderMode < Panel
  height: 40

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  Button
    id: mode
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    height: 18
    text: Rune (SD)

NewComboLeaderWindow < MainWindow
  !text: tr('NewComboLeader')
  size: 440 400
  padding: 25

  Label
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    text: Leaders & Spells

  Label
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Items & Controls

  VerticalScrollBar
    id: contentScroll
    anchors.top: prev.bottom
    margin-top: 3
    anchors.right: parent.right
    anchors.bottom: separator.top
    step: 28
    pixels-scroll: true
    margin-right: -10
    margin-top: 5
    margin-bottom: 5

  ScrollablePanel
    id: content
    anchors.top: prev.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    vertical-scrollbar: contentScroll
    margin-bottom: 10

    Panel
      id: left
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.horizontalCenter
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    Panel
      id: right
      anchors.top: parent.top
      anchors.left: parent.horizontalCenter
      anchors.right: parent.right
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    VerticalSeparator
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.horizontalCenter

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  ResizeBorder
    id: bottomResizeBorder
    anchors.fill: separator
    height: 3
    minimum: 260
    maximum: 600
    margin-left: 3
    margin-right: 3
    background: #ffffff88

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5
]])

local root = rootWidget or g_ui.getRootWidget()
NewComboLeaderWindow = UI.createWindow('NewComboLeaderWindow', root)
NewComboLeaderWindow:hide()
NewComboLeaderWindow.closeButton.onClick = function()
  NewComboLeaderWindow:hide()
end

NewComboLeaderWindow:setHeight(380)
NewComboLeaderWindow:setWidth(450)
NewComboLeaderWindow:setText("New Combo Leader")

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('3 Combo Leader')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.push.onClick = function()
  NewComboLeaderWindow:show()
  NewComboLeaderWindow:raise()
  NewComboLeaderWindow:focus()
end

local rightPanel = NewComboLeaderWindow.content.right
local leftPanel = NewComboLeaderWindow.content.left

local addItem = function(id, title, defaultItem, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderItem', dest)
  widget.text:setText(title)
  widget.text:setTooltip(tooltip)
  widget.item:setTooltip(tooltip)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(itemWidget)
    settings[id] = itemWidget:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.text:setTooltip(tooltip)
  widget.textEdit:setTooltip(tooltip)
  widget.textEdit.onTextChange = function(_, text)
    settings[id] = text
  end
  settings[id] = settings[id] or defaultValue or ""
end

-- The selected mode is exclusive: a configured missile fires either the rune
-- or the spell, never both.
local comboModeWidget = UI.createWidget('NewComboLeaderMode', leftPanel)
comboModeWidget.text:setText("Combo Mode")
comboModeWidget.text:setTooltip("Choose whether Combo Attack uses the configured rune or spell.")
comboModeWidget.mode:setTooltip("Rune uses the SD item. Spell targets the leader's target and says Combo Spell.")

local function refreshComboMode()
  if settings.comboMode == "spell" then
    comboModeWidget.mode:setText("Spell")
  else
    comboModeWidget.mode:setText("Rune (SD)")
  end
end

comboModeWidget.mode.onClick = function()
  if settings.comboMode == "spell" then
    settings.comboMode = "rune"
  else
    settings.comboMode = "spell"
  end
  refreshComboMode()
end
refreshComboMode()

-- Macro switches placed in the Setup window.
local m_leaderTarget = macro(10000, "Leader Target", function() end, leftPanel)
local m_comboAttack = macro(10000, "Combo Attack", function() end, leftPanel)
local m_comboSpell = macro(10000, "Combo UE", function() end, leftPanel)
local m_configMissile = macro(10000, "Config Trigger", function() end, leftPanel)

-- Hotkey: attacks the closest listed enemy that can be shot.
hotkey(settings.AttackEnemiesHK, "Attack Enemy Listed", function()
  if g_game.isAttacking() then return end

  local enemies = {}
  for _, enemyName in ipairs(storage.playerList.enemyList) do
    local enemy = getCreatureByName(enemyName)
    if enemy then
      local enemyTile = g_map.getTile(enemy:getPosition())
      if enemyTile and enemyTile:canShoot() then
        table.insert(enemies, enemy)
      end
    end
  end

  table.sort(enemies, function(a, b)
    local distA = getDistanceBetween(a:getPosition(), pos())
    local distB = getDistanceBetween(b:getPosition(), pos())
    return distA < distB
  end)

  local target = enemies[1]
  if target then
    g_game.attack(target)
  end
end, leftPanel)

-- Setup fields (right panel).
addTextEdit("LeaderName1", "Leader 1 Name", settings.LeaderName1, rightPanel)
addTextEdit("LeaderName2", "Leader 2 Name", settings.LeaderName2, rightPanel)
addTextEdit("LeaderName3", "Leader 3 Name", settings.LeaderName3, rightPanel)
addTextEdit("LeaderSpell", "Leader UE call", settings.LeaderSpell, rightPanel)
addTextEdit("UE", "Your UE", settings.UE, rightPanel)
addTextEdit("ComboSpell", "Combo Spell", settings.ComboSpell, rightPanel,
  "Spell cast after the configured missile. Example: exori gran vis")
addTextEdit("AttackEnemiesHK", "Attack Enemies HK", settings.AttackEnemiesHK, rightPanel)

-- Item field (left panel).
addItem("SD", "Rune", 3155, leftPanel, "Rune used when Combo Mode is Rune (SD).")
addLabel("", "To configure the trigger, enable 'Config Trigger' and ask a leader to use the desired rune or spell on a target.", leftPanel)
addLabel("", "Set Combo Mode to Spell and fill 'Combo Spell' to cast a spell instead of SD.", leftPanel)

addLabel("title", "Macros_Lheow", leftPanel):setColor("green")

local comboInfo = UI.Label("--Combo Attack--", leftPanel)
comboInfo:setColor("red")

local signatureInfo = UI.Label("~~>> L H E O W <<~~", leftPanel)
signatureInfo:setColor("blue")

local function lower(value)
  return value and value:lower() or ""
end

local function getLeaderIndexByName(name)
  local normalizedName = lower(name)
  if normalizedName == lower(settings.LeaderName1) then return 1 end
  if normalizedName == lower(settings.LeaderName2) then return 2 end
  if normalizedName == lower(settings.LeaderName3) then return 3 end
  return nil
end

local function clearLockIfNotAttacking()
  if not g_game.isAttacking() then
    settings.leaderLock = nil
  end
end

local function canLeaderAct(leaderName)
  clearLockIfNotAttacking()
  local index = getLeaderIndexByName(leaderName)
  if not index then return false end

  if settings.leaderLock ~= nil then
    return settings.leaderLock == index
  end

  return true
end

local function setLockToLeader(leaderName)
  local index = getLeaderIndexByName(leaderName)
  if index then
    settings.leaderLock = index
  end
end

local function hasText(value)
  return type(value) == "string" and value:match("%S") ~= nil
end

-- Performs one exclusive combo action. A spell needs an active target, so it
-- attacks the same creature immediately before saying the configured spell.
local function useComboAction(target)
  if settings.comboMode == "spell" then
    if not hasText(settings.ComboSpell) then
      modules.game_textmessage.displayGameMessage("Configure 'Combo Spell' before using Spell mode.")
      return false
    end

    if g_game.getAttackingCreature() ~= target then
      g_game.attack(target)
    end
    say(settings.ComboSpell)
    return true
  end

  if not settings.SD or settings.SD <= 0 then
    modules.game_textmessage.displayGameMessage("Configure a rune before using Rune mode.")
    return false
  end

  useWith(settings.SD, target)
  return true
end

onMissle(function(missle)
  if not settings.enabled then return end

  local sourcePosition = missle:getSource()
  if sourcePosition.z ~= posz() then return end

  local fromTile = g_map.getTile(sourcePosition)
  local toTile = g_map.getTile(missle:getDestination())
  if not fromTile or not toTile then return end

  local fromCreatures = fromTile:getCreatures()
  local toCreatures = toTile:getCreatures()
  if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end

  local leader = fromCreatures[1]
  local target = toCreatures[1]

  if table.find(storage.playerList.friendList, target:getName(), true) then return end

  local leaderName = lower(leader:getName())
  local targetName = lower(target:getName())
  if targetName == lower(settings.LeaderName1)
    or targetName == lower(settings.LeaderName2)
    or targetName == lower(settings.LeaderName3) then
    return
  end

  local isLeader = leaderName == lower(settings.LeaderName1)
    or leaderName == lower(settings.LeaderName2)
    or leaderName == lower(settings.LeaderName3)
  if not isLeader or not canLeaderAct(leader:getName()) then return end

  setLeaderOutfit(leader)
  setEnemyOutfit(target)

  if m_configMissile.isOn() then
    settings.sdMissle = missle:getId()
    modules.game_textmessage.displayGameMessage("Combo trigger configured.")
    m_configMissile:setOff()
    return
  end

  if m_leaderTarget.isOn() then
    local currentTarget = g_game.getAttackingCreature()
    if not currentTarget or currentTarget ~= target then
      g_game.attack(target)
      setLockToLeader(leader:getName())
      schedule(1000, function()
        g_game.cancelAttackAndFollow()
      end)
    else
      setLockToLeader(leader:getName())
    end
  end

  if m_comboAttack.isOn() and missle:getId() == settings.sdMissle then
    if useComboAction(target) then
      setLockToLeader(leader:getName())
    end
  end
end)

onTalk(function(name, level, mode, text, channelId, talkPosition)
  if not settings.enabled or not m_comboSpell.isOn() then return end

  local normalizedName = lower(name)
  local normalizedText = lower(text)
  local isLeader = normalizedName == lower(settings.LeaderName1)
    or normalizedName == lower(settings.LeaderName2)
    or normalizedName == lower(settings.LeaderName3)

  if not isLeader or normalizedText ~= lower(settings.LeaderSpell) then return end

  if canLeaderAct(name) then
    say(settings.UE)
    setLockToLeader(name)
  end
end)
