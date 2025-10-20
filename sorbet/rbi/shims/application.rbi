# typed: strong

module Rails
  class << self
    sig { returns(InsideReport::Application) }
    def application; end
  end
end
