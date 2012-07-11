require 'rubygems'

require 'active_support/version'

if ActiveSupport::VERSION::MAJOR == 3
  require 'active_support/all'
else
  require 'active_support'
end

require 'nokogiri'
require 'json'
gem('memcache-client')
require 'memcache'

require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/client/net_http'
