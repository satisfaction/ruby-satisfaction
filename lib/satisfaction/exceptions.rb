
module Sfn
  class Error < StandardError; end
  class TooManyRedirects < Error; end
  class BadRequest < Error; end
  class AuthorizationError < Error; end
  class NotFound < Error; end
  class SiteMaintenance < Error; end
end
