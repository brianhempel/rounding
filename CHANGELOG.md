### 2015-04-27 - v1.0.1

- Fix rounding errors when `ActiveSupport::Duration` objects were used. Because of quirks of Ruby, they where coerced into floats even for valid Fixnums like `1.second`. The fix ensures that they are converted to rationals for perfect rounding.
- Allows you to use the gem without `require "date"`. (The gem will not `require "date"` for you.) Previously, the gem errored.

### 2014-09-09 - v1.0.0

Initial Release.
