# Rounding

[![Gem Version](https://badge.fury.io/rb/rounding.svg)](http://badge.fury.io/rb/rounding)
[![Build Status](https://travis-ci.org/brianhempel/rounding.svg)](https://travis-ci.org/brianhempel/rounding)

Rounding allows you to round any numeric value to anything you want. You can also round a Time to, for example, the nearest 15 minutes.

Some quick examples:

```ruby
require 'rounding'

26.round_to(10)               # => 30
8.77.floor_to(2.5)            # => 7.5
101.ceil_to(25)               # => 125
Time.now.round_to(15.minutes) # => 2014-09-08 22:30:00 -0400
```

Rounding is compatible with ActiveSupport's Time extensions, but also works fine without ActiveSupport.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rounding'
```

And then execute:

    $ bundle

Or install it yourself like so:

    $ gem install rounding

## Usage

First, require the gem.

```ruby
require 'rounding'
```

Rounding adds three methods to all Numeric objects: `round_to`, `floor_to`, and `ceil_to`.

`round_to` rounds to the nearest multiple of the chosen step.

```ruby
254.round_to(100) # => 300
1.4.round_to(3)   # => 0
1.5.round_to(3)   # => 3
1.6.round_to(3)   # => 3
-8.round_to(3)    # => -9
```

`floor_to` rounds down to a multiple of the chosen step.

```ruby
299.floor_to(100)  # => 200
1.81.floor_to(0.5) # => 1.5
60.floor_to(15)    # => 60
-8.floor_to(3)     # => -9
```

`ceil_to` rounds up to a multiple of the chosen step.

```ruby
201.ceil_to(100)  # => 300
1.71.ceil_to(0.5) # => 2.0
60.ceil_to(15)    # => 60
-8.ceil_to(3)     # => -6
```

For all methods, the class of the result depends on the input arguments.

```ruby
16.round_to(10)     # => 20
16.round_to(10.0)   # => 20.0
16.0.round_to(10)   # => 20
16.0.round_to(10.0) # => 20.0
```

If you need super-precise rounding, use Rationals.

```ruby
seconds = Time.now.to_f         # => 1410230400.4758651
seconds.round_to(0.0001)        # => 1410230400.4759002 # Float is not exact
seconds.round_to(1.to_r/10_000) # => (14102304004759/10000)
```

You can provide an offset if you want the multiples to start counting from something other than zero.

```ruby
# rounding by 10 with an offset of 3 will round to 3, 13, 23, 33, 43, 53 etc.
18.round_to(10, 3) # => 23
18.floor_to(10, 3) # => 13
18.ceil_to(10, 3)  # => 23
0.ceil_to(10, 3)   # => 3
0.floor_to(10, 3)  # => -7
```

### Usage with Time and TimeWithZone objects

You can round times to whatever you like. The units are seconds.

```ruby
time = Time.now      # => 2014-09-08 22:57:34 -0400

# to next 10 minutes...
time.ceil_to(60*10)  # => 2014-09-08 23:00:00 -0400

# to previous 15 minutes...
time.floor_to(60*15) # => 2014-09-08 22:45:00 -0400

# to nearest hour...
time.round_to(60*60) # => 2014-09-08 23:00:00 -0400
```

If you need to round to something smaller than one second, use rationals to avoid precision loss.

```ruby
time.xmlschema(6)                       # => "2014-09-08T22:57:34.433197-04:00"
time.round_to(1.to_r/1000).xmlschema(6) # => "2014-09-08T22:57:34.433000-04:00"
```

Times are rounded in their time zone.

```ruby
ONE_DAY = 60*60*24

time.round_to(ONE_DAY) # => 2014-09-09 00:00:00 -0400
```

If you want to round in UTC, use `round_in_utc_to`, `floor_in_utc_to`, and `ceil_in_utc_to`.

```ruby
time.round_in_utc_to(ONE_DAY) # => 2014-09-08 20:00:00 -0400
time.floor_in_utc_to(ONE_DAY) # => 2014-09-08 20:00:00 -0400
time.ceil_in_utc_to(ONE_DAY)  # => 2014-09-09 20:00:00 -0400
```

If you want the result in UTC instead of the original time zone, convert to UTC first.

```ruby
time.dup.utc.round_to(ONE_DAY) # => 2014-09-09 00:00:00 UTC
```

You can provide a base value to round around.

```ruby
# round to Wednesday

wednesday = Time.parse("2014-09-03 -0400")
one_week  = ONE_DAY*7

time.round_to(one_week, wednesday) # => 2014-09-10 00:00:00 -0400
```

If you've loaded ActiveSupport, you can use ActiveSupport's duration sugar to write expressions like `1.day` instead of `60*60*24`.

```ruby
require "active_support/time"

time.round_to(1.day)     # => 2014-09-09 00:00:00 -0400
time.round_to(5.minutes) # => 2014-09-08 23:00:00 -0400
```

ActiveSupport's TimeWithZone is fully supported.

```ruby
time = ActiveSupport::TimeZone["Bern"].parse("2014-09-08 22:57:34 -0400")
# => Tue, 09 Sep 2014 04:57:34 CEST +02:00

time.round_to(12.hours)       # => Tue, 09 Sep 2014 00:00:00 CEST +02:00
time.round_to(12.hours).class # => ActiveSupport::TimeWithZone
```

For rounding to the month or year, you should use ActiveSupport's time extensions. Months and years have variable numbers of days and thus are not correctly supported by Rounding.

### Usage with DateTime objects

Rounding also works with DateTime objects. Unlike Time objects, you will be rounding to a chosen number of days rather than a number of seconds.

```ruby
require 'date'

date_time = DateTime.now # => Mon, 08 Sep 2014 23:46:16 -0400

date_time.round_to(1)    # => Tue, 09 Sep 2014 00:00:00 -0400
```

Use rational fractions of a day to round to the desired unit.

```ruby
# 1 hour
date_time.floor_to(1.to_r/24)      # => Mon, 08 Sep 2014 23:00:00 -0400
# 5 minutes
date_time.floor_to(1.to_r/24/60*5) # => Mon, 08 Sep 2014 23:45:00 -0400
```

ActiveSupport's duration helpers can save you from writing ugly expressions.

```ruby
date_time.floor_to(1.hour)    # => Mon, 08 Sep 2014 23:00:00 -0400
date_time.floor_to(5.minutes) # => Mon, 08 Sep 2014 23:45:00 -0400
```

The `round_in_utc_to`, `floor_in_utc_to`, and `ceil_in_utc_to` are also available on DateTime objects. However, to round around the UNIX epoch in your time zone, you will need to provide a custom center for rounding.

```ruby
fortnight = 2.weeks
unix_epoch_minus_four = DateTime.new(1970, 1, 1, 0, 0, 0, "-0400")

# UNIX epoch is a Thursday in UTC, Julian epoch is a Monday

date_time.round_to(fortnight)                        # => Mon, 15 Sep 2014 00:00:00 -0400
date_time.round_in_utc_to(fortnight)                 # => Wed, 10 Sep 2014 20:00:00 -0400
date_time.round_to(fortnight, unix_epoch_minus_four) # => Thu, 11 Sep 2014 00:00:00 -0400
```

Happy rounding!

## Changelog

### 2015-04-27 - v1.0.1

- Fix rounding errors when `ActiveSupport::Duration` objects were used. Because of quirks of Ruby, they where coerced into floats even for valid Fixnums like `1.second`. The fix ensures that they are converted to rationals for perfect rounding.
- Allows you to use the gem without `require "date"`. (The gem will not `require "date"` for you.) Previously, the gem errored.

### 2014-09-09 - v1.0.0

Initial Release.

## License

Rounding is dedicated to the public domain by its author, Brian Hempel. No rights are reserved. No restrictions are placed on the use of Rounding. That freedom also means, of course, that no warrenty of fitness is claimed; use Rounding at your own risk.

This public domain dedication follows the the CC0 1.0 at https://creativecommons.org/publicdomain/zero/1.0/

## Contributing

1. Fork it ( https://github.com/brianhempel/rounding/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests with `rspec`
4. There is also a `bin/console` command to load up a REPL for playing around
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request
