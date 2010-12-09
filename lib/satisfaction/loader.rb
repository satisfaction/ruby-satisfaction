require 'net/http'
require 'uri'


class Sfn::Loader
  require 'satisfaction/cache/hash'
  require 'satisfaction/cache/memcache'

  CacheRecord = Struct.new(:url, :etag, :body)
  attr_reader :cache
  attr_reader :options
  
  def initialize(options={})
    @options = options.reverse_merge({:cache => :hash})
    reset_cache
  end
  
  def reset_cache
    @cache =  case @options[:cache]
              when :hash then HashCache.new
              when :memcache then MemcacheCache.new(@options[:memcache] || {})
              else
                raise ArgumentError, "Invalid cache spec: #{@options[:cache]}"
              end
  end
  
  def get(url, options = {})
    uri = get_uri(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    cache_record = cache.get(uri)
    
    if cache_record && !options[:force]
      request["If-None-Match"] = cache_record.etag
    end
    
    http = Net::HTTP.new(uri.host, uri.port)
    add_authentication(request, http, options)
    response = execute(http, request)
    
    case response
    when Net::HTTPSuccess
      cache.put(uri, response)
      [:ok, response.body]
    when Net::HTTPMovedPermanently, Net::HTTPMovedTemporarily
      limit = options[:redirect_limit] || 3
      raise Sfn::TooManyRedirects, "Too many redirects" unless limit > 0
      get(response['location'], options.merge(:redirect_limit => limit - 1))
    when Net::HTTPBadRequest
      raise Sfn::BadRequest, "Bad request. Response body:\n" + response.body
    when Net::HTTPForbidden, Net::HTTPUnauthorized
      raise Sfn::AuthorizationError, "Not authorized"
    when Net::HTTPNotFound
      raise Sfn::NotFound, "Not found"
    when Net::HTTPServiceUnavailable
      raise Sfn::SiteMaintenance, maintenance_message(response.body)
    else
      raise Sfn::Error, "Encountered error. Body of response:\n" + response.body
    end
  end

  def post(url, options)
    uri = get_uri(url)
    form = options[:form] || {}
    method_klass =  case options[:method]
                    when :put     then Net::HTTP::Put
                    when :delete  then Net::HTTP::Delete
                    else
                       Net::HTTP::Post
                    end
                    
    request = method_klass.new(uri.request_uri)
    
    request.set_form_data(form)
    
    http = Net::HTTP.new(uri.host, uri.port)
    add_authentication(request, http, options)
    response = execute(http, request)
    
    case response
    when Net::HTTPForbidden, Net::HTTPUnauthorized
      raise Sfn::AuthorizationError, "Not authorized"
    when Net::HTTPNotFound
      raise Sfn::NotFound, "Not found"
    when Net::HTTPBadRequest
      raise Sfn::BadRequest, "Bad request. Response body:\n" + response.body
    when Net::HTTPSuccess
      [:ok, response.body]
    when Net::HTTPMethodNotAllowed
      #Post responds differently when the site is down for maintenance.
      #This will raise an error if site is down otherwise we will return method_not_allowed.
      get(url)

      raise Sfn::MethodNotAllowed, "Method not allowed"
    when Net::HTTPServiceUnavailable
      raise Sfn::SiteMaintenance, maintenance_message(response.body)
    else
      raise Sfn::Error, "Encountered error. Body of response:\n" + response.body
    end
  end
  
  private
  def execute(http, request)
    http.start{|http| http.request(request) }
  end
  
  def get_uri(url)
    case url
    when URI then url
    when String then URI.parse(url)
    else
      raise ArgumentError, "Invalid uri, please use a String or URI object"
    end
  end
  
  def add_authentication(request, http, options)
    if options[:user]
      request.basic_auth(options[:user], options[:password])
    elsif options[:consumer]
      request.oauth!(http, options[:consumer], options[:token])
    end
  end

  def maintenance_message(html = '')
    Nokogiri::HTML(html).at('.error_message_summary').text
  rescue
    "The site is down for maintenance. Please try again later."
  end
  
end
