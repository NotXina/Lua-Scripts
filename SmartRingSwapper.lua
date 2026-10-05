-- ============================================================================
-- SMART RING SWAPPER (RING INVERTIDO - COM SLOT CONFIGURÁVEL)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

-- Destrói painel anterior para não acumular processos na memória
if smartRingPanel then
  smartRingPanel:destroy()
  smartRingPanel = nil
end

storage.secRingId = storage.secRingId or 14557
storage.smartRingEnabled = storage.smartRingEnabled or false
local eRingId = 3051 -- ID fixo do Energy Ring

local ui = setupUI([[
Panel
  id: smartRingPanelWidget
  height: 34

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 33
    font: verdana-11px-rounded
    !text: tr('Smart Ring')

  BotItem
    id: ringSlot
    anchors.top: parent.top
    anchors.left: prev.right
    margin-left: 6
    width: 33
    height: 33
]], parent)

smartRingPanel = ui

-- Estado inicial do botão
ui.title:setOn(storage.smartRingEnabled)

-- Toggle On/Off
ui.title.onClick = function(widget)
  local newState = not widget:isOn()
  widget:setOn(newState)
  storage.smartRingEnabled = newState
end

-- Slot do Anel (Drag & Drop)
ui.ringSlot:setItemId(storage.secRingId)
ui.ringSlot.onItemChange = function(widget)
  storage.secRingId = widget:getItemId()
end

-- ============================================================================
-- LÓGICA DE TROCA PROTEGIDA CONTRA FLOOD (400ms)
-- ============================================================================
macro(400, function()
  if not storage.smartRingEnabled then return end

  local hp = hppercent()
  local mp = manapercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local configuredRing = storage.secRingId or 14557

  -- 1. Se HP <= 85% OU Mana >= 60%: Equipa Energy Ring (3051)
  if hp <= 85 or (hp > 85 and mp >= 60) then
    if currentRingId ~= eRingId then
      local ringItem = findItem(eRingId)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500) -- Aguarda resposta do servidor para não travar o cliente
      end
    end

  -- 2. Se HP > 85% e Mana < 60%: Equipa o Anel do Slot
  elseif hp > 85 and mp < 60 then
    if configuredRing > 0 and currentRingId ~= configuredRing then
      local ringItem = findItem(configuredRing)
      if ringItem then
        moveToSlot(ringItem, SlotFinger)
        delay(500)
      end
    end
  end
end)
