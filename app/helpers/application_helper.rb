module ApplicationHelper
  def uncontained_layout?
    @uncontained_layout || false
  end

  def uncontained_layout!
    @uncontained_layout = true
  end

  # List of Google Fonts Material Icons to include. These have to be in alphabetical
  # order, so it's easier to define an Array and sort it for safety:
  #
  def material_icon_list
    %w[
      bedtime
      calculate
      download_2
      notifications_active
      refresh
      sensors
      trending_down
      trending_up
      trophy
    ].sort.join(",")
  end

  def user_signed_in?
    session[:current_user_id].present?
  end

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)
    @current_user = User.find(session[:current_user_id])
  end

  # Determine if we should use Cap for bot protection on sign-up.
  #
  def use_cap?
    return false unless Rails.env.production?
    cap_endpoint.present?
  end

  def cap_endpoint
    url = Rails.application.credentials.dig(:cap, :url)
    site_key = Rails.application.credentials.dig(:cap, :site_key)
    return nil unless url.present? && site_key.present?

    URI.join(url, site_key).to_s
  end

  def use_plausible?
    return false unless Rails.env.production?
    Rails.application.credentials.dig(:plausible, :src).present?
  end
end
