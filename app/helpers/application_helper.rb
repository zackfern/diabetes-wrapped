module ApplicationHelper
  def uncontained_layout?
    @uncontained_layout || false
  end

  def uncontained_layout!
    @uncontained_layout = true
  end

  def material_icon_list
    %w[
      bedtime
      calculate
      notifications_active
      sensors
      trending_down
      trending_up
      trophy
    ].sort.join(",")
  end
end
