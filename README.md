# Katakuchi

片口: 鉢で，取っ手がなく一方に注ぎ口の突き出ているもの。

## Installation

Add this line to your application's Gemfile:

    gem 'katakuchi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install katakuchi

## Usage

`app/models/user.rb`

```ruby
class User < ActiveRecord::Base
  # columns: name, email
end
```

`app/roles/writer.rb`

```ruby
class Writer
  include Katakuchi::Role

  def write
    "Hello, #{self.name}"
  end
end
```

in any controller.

```
def index
  @writers = Writer.all # => User.all.map{|user| user.extend(Writer) }
  @writers.each(&:write)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
