class Nightscout
  include HTTParty

  class Error < StandardError; end
  class HostResolutionError < Error; end
  class SSLError < Error; end
  class UnauthorizedError < Error; end

  attr_accessor :base_uri, :base_query

  def initialize(host, token)
    @base_uri = HTTParty.normalize_base_uri(host + "/api/v1/").freeze
    @base_query = { token: }.freeze
  end

  def on_date(date)
    minimum_ts = date.beginning_of_day.utc.to_fs(:iso8601)
    maximum_ts = date.end_of_day.utc.to_fs(:iso8601)
    find = { dateString: { :$gte => minimum_ts, :$lte => maximum_ts } }
    response = entries(count: 1000, find:).parsed_response
    response.sort_by { |i| i["date"] }
  end

  def treatments_on_date(date)
    minimum_ts = date.beginning_of_day.utc.to_fs(:iso8601)
    maximum_ts = date.end_of_day.utc.to_fs(:iso8601)
    find = { created_at: { :$gte => minimum_ts, :$lte => maximum_ts } }
    response = treatments(count: 1000, find:).parsed_response
    response.sort_by { |i| DateTime.parse(i["created_at"]) }
  end

  def between(min, max)
    minimum_ts = min.to_fs(:iso8601)
    maximum_ts = max.to_fs(:iso8601)
    find = { dateString: { :$gte => minimum_ts, :$lte => maximum_ts } }
    response = entries(count: 1000, find:).parsed_response
    response.sort_by { |i| i["date"] }
  end

  def treatments_between(min, max)
    minimum_ts = min.to_fs(:iso8601)
    maximum_ts = max.to_fs(:iso8601)
    find = { dateString: { :$gte => minimum_ts, :$lte => maximum_ts } }
    response = treatments(count: 1000, find:).parsed_response
    response.sort_by { |i| i["date"] }
  end

  def latest
    entries(count: 1).first
  end

  def latest_treatment
    treatments(count: 1)
  end

  def entries(count: 10, find: nil)
    query = build_query({ count: })
    query[:find] = find if find.present?

    get("/entries.json", { base_uri:, query: })
  end

  def treatments(count: 10, find: nil)
    query = build_query({ count: })
    query[:find] = find if find.present?

    get("/treatments.json", { base_uri:, query: })
  end

  private
  def build_query(q)
    base_query.merge(q)
  end

  def get(*args)
    begin
      result = self.class.get(*args)

      if result.success?
        result
      elsif result.unauthorized?
        raise UnauthorizedError.new
      else
        raise Error.new(result.status)
      end
    rescue OpenSSL::SSL::SSLError
      raise SSLError.new
    rescue Socket::ResolutionError
      raise HostResolutionError.new
    end
  end
end
