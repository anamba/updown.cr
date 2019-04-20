# updown.cr - updown.io API helper

[![Version](https://img.shields.io/github/tag/anamba/updown.cr.svg?maxAge=360)](https://github.com/anamba/updown.cr/releases/latest)
[![License](https://img.shields.io/github/license/anamba/updown.cr.svg)](https://github.com/anamba/updown.cr/blob/master/LICENSE)
<!-- [![Build Status](https://travis-ci.org/anamba/updown.cr.svg?branch=master)](https://travis-ci.org/anamba/updown.cr) -->

See [updown.io API Docs](https://updown.io/api) for more information on available endpoints and parameters.

**Status:** Works, but error handling is pretty rough (API documentation is a little sparse in this area, so it needs more real-world testing). Please open issues for anything you that could be improved.

Also need to figure out how to do a Travis build without exposing an API key to the world.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     updown:
       github: anamba/updown.cr
   ```

2. Run `shards install`

## Usage

Configure API key either by setting UPDOWN_API_KEY in your environment or `Updown.settings.api_key = "your key here"`.

```crystal
require "updown"

# create a new check
check = Updown::Check.new("https://updown.io")
check.save

# list all existing checks
checks = Updown::Check.all
check = checks.last.get # re-fetch with metrics

# find a single check - to find token, either use `Updown::Check.all`
# or look at check page url (https://updown.io/[token])
check = Updown::Check.get("token")

# change attributes and save
check.period       # 300
check.period = 60  # 60
check.save         # true (or Updown::Error)
```

All methods that call the Updown API raise `Updown::Error` on a non-200 response code.

## Contributing

1. Fork it (<https://github.com/anamba/updown.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Aaron Namba](https://github.com/anamba) - creator and maintainer
