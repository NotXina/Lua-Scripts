-- ============================================================================
-- EMERGENCY ENERGY RING SWAPPER (COM SLOT CONFIGURÁVEL)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

-- Destrói painel anterior para não acumular processos na memória
if emergencyRingPanel then
  emergencyRingPanel:destroy()
  emergencyRingPanel = nil
end

storage.emergencySecRingId = storage.emergencySecRingId or 3048 -- Anel padrão (ex: 3048 = Might Ring / 14557 = Prismatic)
storage.emergencyRingEnabled = storage.emergencyRingEnabled or false

local eRingId = 3051 -- ID do Energy Ring
local equipERingHp = 60 -- Equipa Energy Ring com 60% de HP ou menos
local unequipERingHp = 80 -- Tira o Energy Ring e volta o anel normal com 80% de HP ou mais

-- Interface: Botão de alternar + Slot do Anel (Drag & Drop)
local ui = setupUI([[
Panel
  id: emergencyRingPanelWidget
  height: 34

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 33
    font: verdana-11px-rounded
    !text: tr('Emergency Ring')

  BotItem
    id: ringSlot
    anchors.top: parent.top
    anchors.left: prev.right
    margin-left: 6
    width: 33
    height: 33
]], parent)

emergencyRingPanel = ui

-- Estado inicial do botão
ui.title:setOn(storage.emergencyRingEnabled)

-- Evento Toggle On/Off
ui.title.onClick = function(widget)
  local newState = not widget:isOn()
  widget:setOn(newState)
  storage.emergencyRingEnabled = newState
end

-- Slot do Anel Normal (Drag & Drop)
ui.ringSlot:setItemId(storage.emergencySecRingId)
ui.ringSlot.onItemChange = function(widget)
  storage.emergencySecRingId = widget:getItemId()
end

-- ============================================================================
-- LÓGICA DE TROCA INTELIGENTE (ZERO LAG - 250ms)
-- ============================================================================
macro(250, function()
  if not storage.emergencyRingEnabled then return end

  local hp = hppercent()
  local currentRing = getFinger()
  local currentRingId = currentRing and currentRing:getId() or 0
  local normalRingId = storage.emergencySecRingId or 0

  -- 1. EMERGÊNCIA (HP <= 60%): Equipa o Energy Ring
  if hp <= equipERingHp then
    if currentRingId ~= eRingId then
      local eRingItem = findItem(eRingId)
      if eRingItem then
        moveToSlot(eRingItem, SlotFinger)
        delay(400) -- Delay de segurança para não travar o cliente
      end
    end

  -- 2. SEGURO (HP >= 80%): Tira o Energy Ring e volta o Anel configurado
  elseif hp >= unequipERingHp then
    if normalRingId > 0 and currentRingId ~= normalRingId then
      local normalRingItem = findItem(normalRingId)
      if normalRingItem then
        moveToSlot(normalRingItem, SlotFinger)
        delay(400) -- Delay de segurança
      end
    end
  end
end)
