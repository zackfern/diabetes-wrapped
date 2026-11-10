module ApplicationHelper
  def uncontained_layout?
    @uncontained_layout || false
  end

  def uncontained_layout!
    @uncontained_layout = true
  end
end
