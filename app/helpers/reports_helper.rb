module ReportsHelper
  include ActiveSupport::NumberHelper

  # Helper which will either return a flat Integer representation of a number,
  # if it's a round number, or the Float representation if not:
  #
  def display_number(n)
    n.to_i == n ? n.to_i : n
  end

  # Helper which:
  # - Rounds a number.
  # - Will only display the fraction if necessary.
  # - Delimits the number.
  #
  # e.g. rounded_number_delimited(1234.567) => 1,234.57
  #      rounded_number_delimited(1234.0) => 1,234
  def rounded_number_delimited(n)
    number_to_delimited display_number(n.round(2))
  end

  def viewer_is_owner?
    return false unless session[:current_user_id].present?
    return false unless @report.present?

    session[:current_user_id] == @report.user_id
  end

  def bg_with_unit(bg, small = true)
    # Convert mg/dL to mmol/L if necessary:
    if @report.unit == "mmol/L"
      bg = (bg / 18.016).round(1)
      bg = display_number(bg)
    end

    content_tag(:strong, bg) +
      " ".html_safe +
      content_tag(:span, @report.unit, class: "unit #{small ? 'small' : ''}")
  end
end
