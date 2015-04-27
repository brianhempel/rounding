module Rounding::TimeExtensions
  def floor_to(step, around=-utc_offset)
    step = step.to_r
    around = around.to_r
    rational_self = self.to_r
    difference = rational_self - rational_self.floor_to(step, around)
    self - difference
  end

  def ceil_to(step, around=-utc_offset)
    step = step.to_r
    around = around.to_r
    rational_self = self.to_r
    difference = rational_self - rational_self.ceil_to(step, around)
    self - difference
  end

  def round_to(step, around=-utc_offset)
    step = step.to_r
    around = around.to_r
    rational_self = self.to_r
    difference = rational_self - rational_self.round_to(step, around)
    self - difference
  end

  def floor_in_utc_to(step)
    floor_to(step, 0)
  end

  def ceil_in_utc_to(step)
    ceil_to(step, 0)
  end

  def round_in_utc_to(step)
    round_to(step, 0)
  end
end
