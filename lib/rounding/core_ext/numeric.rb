class Numeric
  def floor_to(step, around=0)
    whole, _ = (self - around).divmod(step)
    whole * step + around
  end

  def ceil_to(step, around=0)
    whole, remainder = (self - around).divmod(step)
    num_steps = remainder > 0 ? whole + 1 : whole
    num_steps * step + around
  end

  def round_to(step, around=0)
    whole, remainder = (self - around).divmod(step)
    num_steps = remainder*2 >= step ? whole + 1 : whole
    num_steps * step + around
  end
end
