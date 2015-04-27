require 'rounding/time_extensions'

# Don't explode if you are not using Dates.
class Date
end

class DateTime < Date
  include Rounding::TimeExtensions

  UNIX_EPOCH = 2440588

  raise "DateTime#to_r already defined! Definitions may conflict" if method_defined?(:to_r)
  def to_r
    no_offset = new_offset(0)
    no_offset.jd + no_offset.day_fraction
  end

  def floor_to(step, around=-offset)
    step   = decode_duration(step)
    around = decode_duration(around)
    super(step, around)
  end

  def ceil_to(step, around=-offset)
    step   = decode_duration(step)
    around = decode_duration(around)
    super(step, around)
  end

  def round_to(step, around=-offset)
    step   = decode_duration(step)
    around = decode_duration(around)
    super(step, around)
  end

  def floor_in_utc_to(step)
    floor_to(step, UNIX_EPOCH)
  end

  def ceil_in_utc_to(step)
    ceil_to(step, UNIX_EPOCH)
  end

  def round_in_utc_to(step)
    round_to(step, UNIX_EPOCH)
  end

  private

  def decode_duration(value)
    if defined?(ActiveSupport::Duration) && ActiveSupport::Duration === value
      value.to_r / 1.day.to_r
    else
      value
    end
  end
end
