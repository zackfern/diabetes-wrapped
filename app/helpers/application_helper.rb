module ApplicationHelper
  def hide_header?
    @hide_header || false
  end

  def hide_header!
    @hide_header = true
  end
end
