module HotelExampleSiteApiExceptions
  class UnauthorizedError < ActionController::BadRequest; end
  class BadRequestError < ActionController::BadRequest
    attr_reader :message, :details

    def initialize(message = nil, details = [])
      @message = message
      @details = details
    end
  end
end
