class NightscoutValidator < ActiveModel::Validator
  def validate(record)
    return if record.nightscout_host.blank? || record.nightscout_token.blank?

    begin
      # Try querying the Nightscout server.
      record.nightscout.latest
    rescue Nightscout::Error => e
      # And if we get a failure, add an error:
      case e
      when Nightscout::UnauthorizedError
        record.errors.add :nightscout_token, "Recieved unauthorized response when accessing your Nightscout server, please double check your token."
      when Nightscout::HostResolutionError
        record.errors.add :nightscout_host, "Recieved a host resolution error when accessing your Nightscout server, please double check your host."
      when Nightscout::SSLError
        record.errors.add :nightscout_host, "Recieved an SSL error when accessing your Nightscout server, please double check your host."
      else
        record.errors.add :nightscout_host, "An unknown error occurred while trying to connect to your Nightscout server."
      end
    end
  end
end
