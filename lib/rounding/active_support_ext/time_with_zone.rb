require 'rounding/time_extensions'

module ActiveSupport
  class TimeWithZone
    include Rounding::TimeExtensions
  end
end
