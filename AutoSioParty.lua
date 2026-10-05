-- ============================================================================
-- AUTO SIO PARTY / FRIEND (COM SETUP WINDOW)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.sioFriendSettings = storage.sioFriendSettings or {
  enabled = false,
  sioHealth = 70,
  minMyHp = 50
}
local settings = storage.sioFriendSettings

if sioFriendWindow then sioFriendWindow:destroy() end

g_ui.loadUIFromString([[
SioFriendWindow < MainWindow
  text: Sio Friend Setup
  size: 210 180
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    id: hpLabel
    text-align: center
    text: Curar amigos abaixo de: 70% HP
    margin-top: 5

  HorizontalScrollBar
    id: hpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 5

  HorizontalSeparator
    margin-top: 8

  Label
    id: myHpLabel
    text-align: center
    text: Meu HP minimo para Sio: 50%
    margin-top: 3

  HorizontalScrollBar
    id: myHpScroll
    minimum: 1
    maximum: 100
    step: 1
    margin-top: 5

  HorizontalSeparator
    margin-top: 8

  Button
    id: closeButton
    text: Close
    font: cipsoftFont
    margin-top: 5
    margin-left: 145
    width: 45
    height: 21
]])

sioFriendWindow = UI.createWindow('SioFriendWindow', g_ui.getRootWidget())
sioFriendWindow:hide()

sioFriendWindow.hpScroll:setValue(settings.sioHealth or 70)
sioFriendWindow.hpLabel:setText("Curar amigos abaixo de: " .. (settings.sioHealth or 70) .. "% HP")
sioFriendWindow.hpScroll.onValueChange = function(w, v)
  settings.sioHealth = v
  sioFriendWindow.hpLabel:setText("Curar amigos abaixo de: " .. v .. "% HP")
end

sioFriendWindow.myHpScroll:setValue(settings.minMyHp or 50)
sioFriendWindow.myHpLabel:setText("Meu HP minimo para Sio: " .. (settings.minMyHp or 50) .. "%")
sioFriendWindow.myHpScroll.onValueChange = function(w, v)
  settings.minMyHp = v
  sioFriendWindow.myHpLabel:setText("Meu HP minimo para Sio: " .. v .. "%")
end

sioFriendWindow.closeButton.onClick = function()
  sioFriendWindow:hide()
end

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Sio Friend')

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
  sioFriendWindow:show()
  sioFriendWindow:raise()
  sioFriendWindow:focus()
end

macro(200, function()
  if not settings.enabled then return end
  if hppercent() < (settings.minMyHp or 50) then return end

  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:isPlayer() and not spec:isLocalPlayer() and (spec:getShield() >= 3 or spec:getEmblem() == 1 or isFriend(spec:getName())) then
      if spec:getHealthPercent() <= (settings.sioHealth or 70) and spec:getHealthPercent() > 0 then
        say('Exura Sio "' .. spec:getName())
        delay(400)
        return
      end
    end
  end
end)
