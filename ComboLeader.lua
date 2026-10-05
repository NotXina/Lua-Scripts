-- ============================================================================
-- COMBO LEADER (ATAQUE SINCRONIZADO DE GUILD - COM SETUP)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

storage.comboLeaderSettings = storage.comboLeaderSettings or {
  enabled = false,
  leaderName = "Leader Name"
}
local settings = storage.comboLeaderSettings

if comboLeaderWindow then comboLeaderWindow:destroy() end

g_ui.loadUIFromString([[
ComboLeaderWindow < MainWindow
  text: Combo Leader Setup
  size: 210 140
  @onEscape: self:hide()
  layout:
    type: verticalBox
    fit-children: true

  Label
    text-align: center
    text: Nome do Lider:
    margin-top: 5

  TextEdit
    id: leaderText
    margin-top: 5
    text-align: center

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

comboLeaderWindow = UI.createWindow('ComboLeaderWindow', g_ui.getRootWidget())
comboLeaderWindow:hide()

comboLeaderWindow.leaderText:setText(settings.leaderName or "Leader Name")
comboLeaderWindow.leaderText.onTextChange = function(w, text)
  settings.leaderName = text
end

comboLeaderWindow.closeButton.onClick = function()
  comboLeaderWindow:hide()
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
    !text: tr('Combo Leader')

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
  comboLeaderWindow:show()
  comboLeaderWindow:raise()
  comboLeaderWindow:focus()
end

macro(50, function()
  if not settings.enabled then return end
  local lName = settings.leaderName
  if not lName or lName == "Leader Name" or lName == "" then return end
  
  for _, spec in ipairs(getSpectators(posz(), false) or {}) do
    if spec:getName():lower() == lName:lower() then
      local leaderTarget = spec:getAttackingCreature()
      if leaderTarget and g_game.getAttackingCreature() ~= leaderTarget then
        g_game.attack(leaderTarget)
      end
      return
    end
  end
end)
