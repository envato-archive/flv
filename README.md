# FLV

A Ruby library for parsing FLV files and metadata sections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "flv"
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install flv
```

## Usage

```ruby
flv = FLV.read("path/to/your/video.flv")
flv.audio? # => true
flv.video? # => true

data_tag = flv.tags.find { |tag| tag.is_a?(FLV::Tag::Data) }
data_tag.duration # => 60.0
data_tag.frame_rate # => 30.0
```

The FLV gem also supports streaming parsing, so you can handle tags as they arrive from an I/O stream.

This is useful for pulling metadata out of FLV videos without having to download the whole lot:

```ruby
flv = FLV.new(io)
data_tag = flv.each_tag.first
io.close
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
