class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def render_404
    respond_to do |f|
      f.html { render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found }
      f.any  { head :not_found }
    end
  end
end
