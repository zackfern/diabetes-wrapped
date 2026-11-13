class Cap
  include HTTParty

  base_uri Rails.application.credentials.dig(:cap, :url)

  def validate(token)
    options = {
      body: {
        secret: Rails.application.credentials.dig(:cap, :secret),
        response: token
      }.to_json,
      headers: {
        "Content-Type" => "application/json"
      }
    }

    self.class.post("/#{Rails.application.credentials.dig(:cap, :site_key)}/siteverify", options)
  end
end
