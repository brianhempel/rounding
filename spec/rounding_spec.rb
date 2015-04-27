$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rounding"
require "date"
require "active_support/time"

TIME_ZONE = ActiveSupport::TimeZone["Bern"]
AST       = ActiveSupport::TimeZone["Kuwait"] # something without DST

ONE_DAY   = 60*60*24
ONE_WEEK  = ONE_DAY * 7
WEDNESDAY = Time.new(2014, 9, 3, 0, 0, 0, "-06:00")

describe "Rounding" do

  def self.it_rounds_correctly(method, input, step, expected)
    it "should be #{expected.inspect} for #{input.class} #{input.inspect} step by #{step.inspect}" do
      result = input.send(method, step)
      expect(result).to eq(expected)
    end

    it "should be class #{expected.class.inspect} for #{input.inspect} step by #{step.inspect}" do
      result = input.send(method, step)
      expect(result.class).to eq(expected.class)
    end

    if input.respond_to?(:utc_offset)
      it "should have utc_offset #{expected.utc_offset.inspect} for #{input.inspect} step by #{step.inspect}" do
        result_utc_offset = input.send(method, step).utc_offset
        expect(result_utc_offset).to eq(expected.utc_offset)
      end
    end

    if input.respond_to?(:offset)
      it "should have offset #{expected.offset.inspect} for #{input.inspect} step by #{step.inspect}" do
        result_offset = input.send(method, step).offset
        expect(result_offset).to eq(expected.offset)
      end
    end
  end

  describe "#floor_to" do
    FLOOR_TO_EXPECTATIONS = {
      [3,     2]   => 2,
      [2,     2]   => 2,
      [0,     2]   => 0,
      [-1,    2]   => -2,
      [-2,    2]   => -2,
      [104,   5]   => 100,
      [3.0,   2]   => 2,
      [2.0,   2]   => 2,
      [0.0,   2]   => 0,
      [-1.0,  2]   => -2,
      [-2.0,  2]   => -2,
      [104.0, 5]   => 100,
      [3,     2.5] => 2.5,
      [-3,    2.5] => -5.0,
      [105,   2.5] => 105.0,
      [4.9,   2.5] => 2.5,
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-06:00"),
      [Time.new(2014, 9, 5, 11, 59, 59, "-07:00"), ONE_DAY]                   => Time.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY]                   => Time.new(2014, 9, 5,  0, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5, 12,  0, 01, "-09:00"), ONE_DAY]                   => Time.new(2014, 9, 5,  0, 0, 00, "-09:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2013, 12, 21,  0, 0, 00, "-08:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1430438399999999999.to_r/1000000000), 1.second]                => Time.at(1430438399),
      [TIME_ZONE.local(2014, 9, 5, 18, 8, 30), 60]                            => TIME_ZONE.local(2014, 9, 5, 18, 8, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 5,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 5,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 5,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 5,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2014, 6, 6,  0, 0, 00, "-08:00"), # rounds around Julian epoch: -4712-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(1768973894011.to_r/720000), # fractional seconds test
    }

    FLOOR_TO_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:floor_to, input, step, expected)
    end

    it "allows an around offset to center the rounding" do
      expect(4.floor_to(2.5, 1)).to eq(3.5)
      expect(4.5.floor_to(2, 1)).to eq(3.0)
    end

    it "allows a time around offset to center the rounding" do
      time = Time.new(2014, 9, 5, 12,  0, 00, "-06:00")
      expect(time.floor_to(ONE_WEEK, WEDNESDAY)).to eq(Time.new(2014, 9, 3, 0, 0, 0, "-06:00"))
    end
  end

  describe "#ceil_to" do
    CEIL_TO_EXPECTATIONS = {
      [3,     2]   => 4,
      [2,     2]   => 2,
      [0,     2]   => 0,
      [-1,    2]   => 0,
      [-2,    2]   => -2,
      [104,   5]   => 105,
      [3.0,   2]   => 4,
      [2.0,   2]   => 2,
      [0.0,   2]   => 0,
      [-1.0,  2]   => 0,
      [-2.0,  2]   => -2,
      [104.0, 5]   => 105,
      [3,     2.5] => 5.0,
      [-3,    2.5] => -2.5,
      [105,   2.5] => 105.0,
      [4.9,   2.5] => 5.0,
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [Time.new(2014, 9, 5, 11, 59, 59, "-07:00"), 60*60*24]                  => Time.new(2014, 9, 6,  0, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), 60*60*24]                  => Time.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5, 12,  0, 01, "-09:00"), 60*60*24]                  => Time.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2014, 12, 21,  0, 0, 00, "-08:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1430438398000000001.to_r/1000000000), 1.second]                => Time.at(1430438399),
      [TIME_ZONE.local(2014, 9, 5, 18, 8, 30), 60]                            => TIME_ZONE.local(2014, 9, 5, 18, 9, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 6,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 6,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2015, 6, 6,  0, 0, 00, "-08:00"), # rounds around Julian epoch: -4712-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(212276867281321.to_r/86400000), # fractional seconds test
    }

    CEIL_TO_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:ceil_to, input, step, expected)
    end

    it "allows an around offset to center the rounding" do
      expect(4.ceil_to(2.5, 1)).to eq(6.0)
      expect(4.5.ceil_to(2, 1)).to eq(5.0)
    end

    it "allows a time around offset to center the rounding" do
      time = Time.new(2014, 9, 5, 12,  0, 00, "-06:00")
      expect(time.ceil_to(ONE_WEEK, WEDNESDAY)).to eq(Time.new(2014, 9, 10, 0, 0, 0, "-06:00"))
    end
  end

  describe "#round_to" do
    TO_NEAREST_EXPECTATIONS = {
      [3,     2]   => 4,
      [2,     2]   => 2,
      [0,     2]   => 0,
      [-1,    2]   => 0,
      [-2,    2]   => -2,
      [102,   5]   => 100,
      [103,   5]   => 105,
      [104,   5]   => 105,
      [105,   5]   => 105,
      [84,   10]   => 80,
      [85,   10]   => 90,
      [3.0,   2]   => 4,
      [2.0,   2]   => 2,
      [0.0,   2]   => 0,
      [-1.0,  2]   => 0,
      [-2.0,  2]   => -2,
      [102.0, 5]   => 100,
      [103.0, 5]   => 105,
      [104.0, 5]   => 105,
      [105.0, 5]   => 105,
      [84.0, 10]   => 80,
      [85.0, 10]   => 90,
      [3,     2.5] => 2.5,
      [-3,    2.5] => -2.5,
      [1.24,  2.5] => 0.0,
      [1.25,  2.5] => 2.5,
      [103,   2.5] => 102.5,
      [104,   2.5] => 105.0,
      [105,   2.5] => 105.0,
      [4.9,   2.5] => 5.0,
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [Time.new(2014, 9, 5, 11, 59, 59, "-07:00"), 60*60*24]                  => Time.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), 60*60*24]                  => Time.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5, 12,  0, 01, "-09:00"), 60*60*24]                  => Time.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2014, 12, 21,  0, 0, 00, "-08:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1430438399500000000.to_r/1000000000), 1.second]                => Time.at(1430438400),
      [Time.at(1430438399499999999.to_r/1000000000), 1.second]                => Time.at(1430438399),
      [TIME_ZONE.local(2014, 9, 5, 18, 8, 30), 60]                            => TIME_ZONE.local(2014, 9, 5, 18, 9, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 5,  0, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 6,  0, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 6,  0, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2014, 6, 6,  0, 0, 00, "-08:00"), # rounds around Julian epoch: -4712-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(212276867281321.to_r/86400000), # fractional seconds test
    }

    TO_NEAREST_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:round_to, input, step, expected)
    end

    it "allows an around offset to center the rounding" do
      expect(4.round_to(2.5, 1)).to eq(3.5)
      expect(4.5.round_to(2, 1)).to eq(5.0)
    end

    it "allows a time around offset to center the rounding" do
      time = Time.new(2014, 9, 5, 12,  0, 00, "-06:00")
      expect(time.round_to(ONE_WEEK, WEDNESDAY)).to eq(Time.new(2014, 9, 3, 0, 0, 0, "-06:00"))
    end
  end

  describe "#floor_in_utc_to" do
    FLOOR_IN_UTC_TO_EXPECTATIONS = {
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-06:00"),
      [Time.new(2014, 9, 5,  4, 59, 59, "-07:00"), 60*60*24]                  => Time.new(2014, 9, 4, 17, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5,  4,  0, 00, "-08:00"), 60*60*24]                  => Time.new(2014, 9, 4, 16, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5,  3,  0, 01, "-09:00"), 60*60*24]                  => Time.new(2014, 9, 4, 15, 0, 00, "-09:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2013, 12, 20,  16, 0, 00, "-08:00"),
      [AST.local(2014, 9, 5, 18, 8, 30), 60*60*24]                            => AST.local(2014, 9, 5, 3, 0, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 4, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 4, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 4, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 4, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 4, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 4, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2013, 12, 20,  16, 0, 00, "-08:00"), # rounds around UTC epoch: 1970-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(1768973894011.to_r/720000), # fractional seconds test
    }

    FLOOR_IN_UTC_TO_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:floor_in_utc_to, input, step, expected)
    end
  end

  describe "#ceil_in_utc_to" do
    CEIL_IN_UTC_TO_EXPECTATIONS = {
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [Time.new(2014, 9, 5,  4, 59, 59, "-07:00"), 60*60*24]                  => Time.new(2014, 9, 5, 17, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5,  4,  0, 00, "-08:00"), 60*60*24]                  => Time.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5,  3,  0, 01, "-09:00"), 60*60*24]                  => Time.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2014, 12, 20,  16, 0, 00, "-08:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [AST.local(2014, 9, 5, 18, 8, 30), 60*60*24]                            => AST.local(2014, 9, 6, 3, 0, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 5, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 5, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2014, 12, 20,  16, 0, 00, "-08:00"), # rounds around UTC epoch: 1970-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(212276867281321.to_r/86400000), # fractional seconds test
    }

    CEIL_IN_UTC_TO_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:ceil_in_utc_to, input, step, expected)
    end
  end

  describe "#round_in_utc_to" do
    TO_NEAREST_IN_UTC_EXPECTATIONS = {
      [Time.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60]                        => Time.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [Time.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [Time.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60]                        => Time.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [Time.new(2014, 9, 5,  4, 59, 59, "-07:00"), 60*60*24]                  => Time.new(2014, 9, 4, 17, 0, 00, "-07:00"),
      [Time.new(2014, 9, 5,  4,  0, 00, "-08:00"), 60*60*24]                  => Time.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [Time.new(2014, 9, 5,  3,  0, 01, "-09:00"), 60*60*24]                  => Time.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [Time.new(2014, 9, 5, 12,  0, 00, "-08:00"), ONE_DAY*365]               => Time.new(2014, 12, 20,  16, 0, 00, "-08:00"),
      [Time.at(1409955065, 284499), 1.to_r/1000]                              => Time.at(1409955065, 284000),
      [Time.at(1409955065, 284500), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [Time.at(1409955065, 284501), 1.to_r/1000]                              => Time.at(1409955065, 285000),
      [AST.local(2014, 9, 5, 18, 8, 30), 60*60*24]                            => AST.local(2014, 9, 6, 3, 0, 00),
      [DateTime.new(2014, 9, 5, 18,  8, 29, "-04:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 8, 00, "-04:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 30, "-05:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-05:00"),
      [DateTime.new(2014, 9, 5, 18,  8, 31, "-06:00"), 60.to_r/ONE_DAY]       => DateTime.new(2014, 9, 5, 18, 9, 00, "-06:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1]                     => DateTime.new(2014, 9, 5, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1]                     => DateTime.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1]                     => DateTime.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 11, 59, 59, "-07:00"), 1.day]                 => DateTime.new(2014, 9, 5, 17, 0, 00, "-07:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 1.day]                 => DateTime.new(2014, 9, 5, 16, 0, 00, "-08:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 01, "-09:00"), 1.day]                 => DateTime.new(2014, 9, 5, 15, 0, 00, "-09:00"),
      [DateTime.new(2014, 9, 5, 12,  0, 00, "-08:00"), 365]                   => DateTime.new(2014, 12, 20,  16, 0, 00, "-08:00"), # rounds around UTC epoch: 1970-01-01 00:00:00
      [DateTime.jd(106138433640660311.to_r/43200000000), 1.to_r/1000/ONE_DAY] => DateTime.jd(212276867281321.to_r/86400000), # fractional seconds test
    }

    TO_NEAREST_IN_UTC_EXPECTATIONS.each do |(input, step), expected|
      it_rounds_correctly(:round_in_utc_to, input, step, expected)
    end
  end
end