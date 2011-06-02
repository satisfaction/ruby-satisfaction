
module Sfn
  class Error < StandardError; end
  class TooManyRedirects < Sfn::Error; end
  class BadRequest < Sfn::Error; end
  class AuthorizationError < Sfn::Error; end
  class NotFound < Sfn::Error; end
  class SiteMaintenance < Sfn::Error; end
  class MethodNotAllowed < Sfn::Error; end
  class BadGateway < Sfn::Error; end
  class GatewayTimeOut < Sfn::Error; end
end
