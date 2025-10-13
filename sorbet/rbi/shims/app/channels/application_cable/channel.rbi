# typed: strong

class ApplicationCable::Channel
  sig { returns(ApplicationCable::Connection) }
  def connection; end
end
