-- ============================================================================
-- COORDENADAS NO MINIMAP
-- Exibe as coordenadas X, Y, Z no canto inferior do minimapa
-- ============================================================================

if modules.game_minimap and modules.game_minimap.minimapWidget then
  local minimap = modules.game_minimap.minimapWidget
  local coordLabel = minimap.coords or g_ui.loadUIFromString([[
Label
  id: coords
  color: white
  font: verdana-11px-rounded
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  text-align: center
  margin-right: 3
  margin-left: 3
  text: ""
]], minimap)

  onPlayerPositionChange(function(newPos, oldPos)
    if coordLabel and newPos then
      coordLabel:setText(newPos.x .. ', ' .. newPos.y .. ', ' .. newPos.z)
    end
  end)
end
