-- ============================================================================
--                   POT FRIEND & GUILD (OTIMIZADO - ZERO LAG)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.PotFriendIcon = storage.PotFriendIcon or {}
local settings = storage.PotFriendIcon

if settings.enabled == nil then settings.enabled = true end
settings.potion = settings.potion or 268
settings.manaPercent = settings.manaPercent or 50
settings.potDistance = settings.potDistance or 3
settings.TalkDelay = settings.TalkDelay or 2
settings.Keyword = settings.Keyword or "p"
settings.channelName = settings.channelName or "party"
settings.WalkToPot = settings.WalkToPot ~= nil and settings.WalkToPot or true

-- Destrói janela anterior para não duplicar na memória
if PotFriendIconWindow then
  PotFriendIconWindow:destroy()
  PotFriendIconWindow = nil
end

-- ============================================================================
-- INTERFACE GRÁFICA (SETUP WINDOW)
-- ============================================================================
g_ui.loadUIFromString([[
PotFriendScrollBar < Panel
  height: 28
  margin-top: 3

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    
  HorizontalScrollBar
    id: scroll
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 100
    step: 1

PotFriendTextEdit < Panel
  height: 40
  margin-top: 7

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
    text-align: center

PotFriendItem < Panel
  height: 34
  margin-top: 7
  margin-left: 20
  margin-right: 20

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.verticalCenter: next.verticalCenter

  BotItem
    id: item
    anchors.top: parent.top
    anchors.right: parent.right

PotFriendCheckBox < BotSwitch
  height: 20
  margin-top: 7

PotFriendIconWindow < MainWindow
  !text: tr('Pot Friend Setup')
  size: 420 330
  padding: 15

  ScrollablePanel
    id: content
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin-bottom: 8
      
    Panel
      id: left
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.horizontalCenter
      margin-right: 8
      layout:
        type: verticalBox
        fit-children: true

    Panel
      id: right
      anchors.top: parent.top
      anchors.left: parent.horizontalCenter
      anchors.right: parent.right
      margin-left: 8
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

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 50 21
]])

local rootWidget = g_ui.getRootWidget()
PotFriendIconWindow = UI.createWindow('PotFriendIconWindow', rootWidget)
PotFriendIconWindow:hide()

PotFriendIconWindow.closeButton.onClick = function()
  PotFriendIconWindow:hide()
end

local leftPanel = PotFriendIconWindow.content.left
local rightPanel = PotFriendIconWindow.content.right

-- Helper: CheckBox
local addCheckBox = function(id, title, defaultValue, dest)
  local widget = UI.createWidget('PotFriendCheckBox', dest)
  widget:setText(title)
  widget.onClick = function()
    widget:setOn(not widget:isOn())
    settings[id] = widget:isOn()
  end
  if settings[id] == nil then settings[id] = defaultValue end
  widget:setOn(settings[id])
end

-- Helper: Item Slot
local addItem = function(id, title, defaultItem, dest)
  local widget = UI.createWidget('PotFriendItem', dest)
  widget.text:setText(title)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(w)
    settings[id] = w:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

-- Helper: TextEdit
local addTextEdit = function(id, title, defaultValue, dest)
  local widget = UI.createWidget('PotFriendTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.textEdit.onTextChange = function(w, text)
    settings[id] = text
  end
  settings[id] = settings[id] or defaultValue or ""
end

-- Helper: ScrollBar
local addScrollBar = function(id, title, min, max, defaultValue, dest)
  local widget = UI.createWidget('PotFriendScrollBar', dest)
  widget.scroll:setRange(min, max)
  widget.scroll.onValueChange = function(scroll, value)
    widget.text:setText(title:gsub("#v", value))
    settings[id] = value
  end
  widget.scroll:setValue(settings[id] or defaultValue)
  widget.text:setText(title:gsub("#v", widget.scroll:getValue()))
end

-- Painel Esquerdo
addItem("potion", "Potion", 268, leftPanel)
addScrollBar("manaPercent", "Pedir pot com #v% MP", 0, 100, 50, leftPanel)
addScrollBar("potDistance", "Distancia max: #v SQMs", 0, 8, 3, leftPanel)
addScrollBar("TalkDelay", "Delay de fala: #vs", 0, 10, 2, leftPanel)
addTextEdit("Keyword", "Palavra-chave", "p", leftPanel)

-- Painel Direito
addTextEdit("channelName", "Chat (party/guild)", "party", rightPanel)
addCheckBox("WalkToPot", "Andar ate amigos para potar", true, rightPanel)

-- ============================================================================
-- BOTÃO NO PAINEL PRINCIPAL DO BOT
-- ============================================================================
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Pot Friend')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], parent)

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.setup.onClick = function()
  PotFriendIconWindow:show()
  PotFriendIconWindow:raise()
  PotFriendIconWindow:focus()
end

-- ============================================================================
-- MACRO 1: PEDIR POTION NO CHAT QUANDO A MANA BAIXAR
-- ============================================================================
macro(1000, function()
  if not settings.enabled then return end

  if manapercent() <= (settings.manaPercent or 50) then
    local chat = getChannelId(settings.channelName or "party")
    if chat then
      sayChannel(chat, settings.Keyword or "p")
      delay((settings.TalkDelay or 2) * 1000)
    end
  end
end)

-- Ícone rápido na tela
addIcon("potGuildIcon", {item={id=settings.potion, count=1}, text="PotGuild"}, function(icon, isOn)
  settings.enabled = isOn
  ui.title:setOn(isOn)
end)

-- ============================================================================
-- MACRO 2: POTAR AMIGO QUANDO ELE PEDIR NO CHAT (ON TALK)
-- ============================================================================
onTalk(function(authorName, level, mode, text, channelId, pos)
  if not settings.enabled then return end
  if authorName:lower() == name():lower() then return end
  if text:lower() ~= (settings.Keyword or "p"):lower() then return end

  local friend = getCreatureByName(authorName)
  if not friend then return end

  local isGuildOrParty = (friend:getEmblem() == 1) or (friend:getShield() >= 3) or isFriend(authorName)
  if not isGuildOrParty then return end

  local myPosition = g_game.getLocalPlayer():getPosition()
  local friendPos = friend:getPosition()
  if not friendPos or friendPos.z ~= myPosition.z then return end

  local dist = getDistanceBetween(myPosition, friendPos)

  if dist <= (settings.potDistance or 3) then
    if settings.WalkToPot and dist > 1 then
      autoWalk(friendPos, 10, {precision=1, ignoreCreatures=true})
    end

    useWith(settings.potion or 268, friend)
    
    schedule(350, function()
      if friend and getDistanceBetween(pos(), friend:getPosition()) <= (settings.potDistance or 3) then
        useWith(settings.potion or 268, friend)
      end
    end)
  end
end)
