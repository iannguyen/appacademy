require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:

    def initialize(req, route_params = {})
      route_params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      route_params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params = route_params
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end

    private

    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }

    def parse_www_encoded_form(www_encoded_form)
      decoded = URI.decode_www_form(www_encoded_form)
      decoded.map! { |pair| pair = parse_key(pair.first), pair.last }
      params = {}
      decoded.each do |pair|
        current = params
        keys = pair.first
        keys[0..-2].each do |key|
          current[key] ||= {}
          current = current[key]
        end
        current[keys.last] ||= pair.last
      end
      params
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']

    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
