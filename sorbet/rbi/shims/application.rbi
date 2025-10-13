# typed: strong

module Rails
  class << self
    sig { returns(DailyData::Application) }
    def application; end
  end
end
