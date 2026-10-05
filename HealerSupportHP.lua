-- ============================================================================
--                   HEALER & SUPPORT (OTIMIZADO - ZERO LAG)
-- Tested on OTCv8 3.2 / vBot 4.8
-- ============================================================================

setDefaultTab("HP")

-- ============================================================================
-- 1. MAGIAS DE CURA (HEALING SPELLS)
-- ============================================================================
UI.Label("Healing spells"):setColor("orange")

storage.healing1 = type(storage.healing1) == "table" and storage.healing1 or {on=false, title="HP%", text="exura", min=51, max=90}
storage.healing2 = type(storage.healing2) == "table" and storage.healing2 or {on=false, title="HP%", text="exura vita", min=0, max=50}

for _, healingInfo in ipairs({storage.healing1, storage.healing2}) do
  local healingmacro = macro(100, function()
    local hp = player:getHealthPercent()
    if healingInfo.max >= hp and hp >= healingInfo.min then
      if TargetBot then 
        TargetBot.saySpell(healingInfo.text)
      else
        say(healingInfo.text)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on)

  UI.DualScrollPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on)
  end)
end

UI.Separator()

-- ============================================================================
-- 2. POÇÕES & RUNAS (POTIONS & HEALING RUNES)
-- ============================================================================
UI.Label("Mana & health potions/runes"):setColor("orange")

storage.hpitem1 = type(storage.hpitem1) == "table" and storage.hpitem1 or {on=false, title="HP%", item=266, min=51, max=90}
storage.hpitem2 = type(storage.hpitem2) == "table" and storage.hpitem2 or {on=false, title="HP%", item=3160, min=0, max=50}
storage.manaitem1 = type(storage.manaitem1) == "table" and storage.manaitem1 or {on=false, title="MP%", item=268, min=51, max=90}
storage.manaitem2 = type(storage.manaitem2) == "table" and storage.manaitem2 or {on=false, title="MP%", item=3157, min=0, max=50}

local isOldClient = g_game.getClientVersion() < 860

for i, healingInfo in ipairs({storage.hpitem1, storage.hpitem2, storage.manaitem1, storage.manaitem2}) do
  local healingmacro = macro(100, function()
    local isHp = (i <= 2)
    local currentPercent = isHp and player:getHealthPercent() or math.min(100, math.floor(100 * (player:getMana() / math.max(1, player:getMaxMana()))))
    
    if healingInfo.max >= currentPercent and currentPercent >= healingInfo.min then
      if TargetBot then 
        TargetBot.useItem(healingInfo.item, healingInfo.subType, player)
      else
        local subType = isOldClient and 1 or 0
        useWith(healingInfo.item, player)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on and healingInfo.item > 100)

  UI.DualScrollItemPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on and healingInfo.item > 100)
  end)
end

UI.Separator()

-- ============================================================================
-- 3. BUFFS & PROTEÇÕES (MANA SHIELD, HASTE & ANTI-PARALYZE)
-- ============================================================================
UI.Label("Mana shield spell:")
UI.TextEdit(storage.manaShield or "utamo vita", function(widget, newText)
  storage.manaShield = newText
end)

local lastManaShield = 0
macro(250, "mana shield", function() 
  local t = now or g_clock.millis()
  if hasManaShield() or (lastManaShield + 2000 > t) then return end
  
  if TargetBot then 
    TargetBot.saySpell(storage.manaShield or "utamo vita")
  else
    say(storage.manaShield or "utamo vita")
  end
  lastManaShield = t
end)

UI.Label("Haste spell:")
UI.TextEdit(storage.hasteSpell or "utani hur", function(widget, newText)
  storage.hasteSpell = newText
end)

macro(500, "haste", function() 
  if hasHaste() then return end
  if TargetBot then 
    TargetBot.saySpell(storage.hasteSpell or "utani hur")
  else
    say(storage.hasteSpell or "utani hur")
  end
end)

UI.Label("Anti paralyze spell:")
UI.TextEdit(storage.antiParalyze or "utani hur", function(widget, newText)
  storage.antiParalyze = newText
end)

macro(50, "anti paralyze", function() 
  if not isParalyzed() then return end
  if TargetBot then 
    TargetBot.saySpell(storage.antiParalyze or "utani hur")
  else
    say(storage.antiParalyze or "utani hur")
  end
  delay(100)
end)
