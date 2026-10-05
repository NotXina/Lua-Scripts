--[[
  Tela Limpa
  Esconde textos, efeitos, danos, mensagens e mísseis enquanto estiver ativada.

  O script funciona como um botão: deixe a macro ligada para limpar a tela
  e desligue-a para voltar ao comportamento normal do cliente.
]]

local telaLimpa = macro(100, "Tela Limpa", function()
  -- A macro serve apenas como botão de ativação/desativação.
end)

-- Esconde as mensagens laranjas na tela, preservando mensagens de fala.
onStaticText(function(thing, text)
  if telaLimpa:isOff() then return end

  if not text:find("says:") then
    g_map.cleanTexts()
  end
end)

-- Esconde sprites e efeitos de magias assim que são adicionados ao mapa.
onAddThing(function(tile, thing)
  if telaLimpa:isOff() then return end

  if thing:isEffect() then
    thing:hide()
  end
end)

-- Esconde danos e outros textos animados.
onAnimatedText(function(thing, text)
  if telaLimpa:isOff() then return end

  thing:hide()
end)

-- Remove mensagens do sistema, magias, curas e danos.
onTextMessage(function(mode, text)
  if telaLimpa:isOff() then return end

  if mode == 18 or mode == 19 or mode == 20 then
    modules.game_textmessage.clearMessages()
  end
end)

-- Esconde mísseis e projéteis.
onMissile(function(missile)
  if telaLimpa:isOff() then return end

  missile:hide()
end)
