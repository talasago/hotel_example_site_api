module HotelExampleSiteApiExceptions
  class BadRequestError < ActionController::BadRequest
    attr_reader :message, :details

    def initialize(message = nil, details = [])
      @message = message
      @details = details
      super(message)
    end
  end

  class UnauthorizedError < ActionController::BadRequest; end
  class ForbiddenError < ActionController::BadRequest; end
  class ConflictError < ActionController::BadRequest; end
end
