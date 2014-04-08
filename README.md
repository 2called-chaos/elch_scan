# ElchScan

Query your MediaElch/XBMC library with Ruby! Easy and powerful search for your media chaos.

  * Query on NFO, source data or file contents
  * e.g.: List movies with actor X but not actor Y and release date was between 2003 and 2010
  * e.g.: List movies with or without local trailers
  * e.g.: List movies with more than one or exactly one audio stream

## Installation

    $ gem install elch_scan

## Usage

First generate a sample configuration by running

   $ elch_scan --generate-config

You will need to specify at least one directory with movies in it. You might want to change other settings as well.


To get a basic list of what you've got run

   $ elch_scan -q

![example](http://files.sven.bmonkeys.net/images/_master_Volumescodebinelch_scan__bash_20140408_072644_20140408_072649.png)

To get a list of available options run

   $ elch_scan --help

    Usage: elch_scan [options]
            --generate-config            Generate sample configuration file in ~/.elch_scan.yml
        -h, --help                       Shows this help
        -v, --version                    Shows version and other info
        -f, --formatter HTML             Use formatter
        -o, --output FILENAME            Write formatted results to file
        -e, --edit SELECT_SCRIPT         Edit selector script
        -s, --select [WITH_SUBS,NO_NFO]  Filter movies with saved selector scripts
        -p, --permute                    Open editor to write permutation code for collection
        -q, --quiet                      Don't ask to filter or save results
        -c, --console                    Start console to play around with the collection

If you choose to create a script or filter on the fly you will find some more examples on this topic.

### Filters

You can easily filter your movies with Ruby. It's not hard, just look at these examples.

```ruby
# Filter by name, for regex see http://rubular.com
collection.select! {|name, movie| movie.name =~ /simpsons/i }

# Rating > 5
collection.select! {|name, movie| movie.nfo!{|n| n["rating"].first.to_f > 5 } }

# 720p or higher
collection.select! { |name, movie| movie.source.width >= 1280 }

# With actor
collection.select! do |name, movie|
  movie.nfo! {|n| n["actor"].map {|actor| actor["name"].first }.include?("Jim Carrey") }
end
```

Note: Use `binding.pry` to start an interactive console so you can easily check out which attributes are available.

### Custom formatters

To add a custom formatter just add the ruby file to your config (you can omit the .rb):

```yml
  formatters:
    - "~/.elch_scan/my_custom_formatter.rb"
```

To write a custom formatter look at the existing ones. You can take this as template:

```ruby
module ElchScan
  module Formatter
    class MyFormatter < Base

      def format(results)
        [].tap do |lines|
          # render your output and append it to lines
          lines << "I have #{results.count} results here..."
          binding.pry # Interactive console will start here!
        end
      end

    end
  end
end
```

You can then use your formatter by passing `-f MyFormatter`, it's case sensitive!


## ToDo

[] Add HTML formatter
[] Add support for TV shows

## Contributing

1. Fork it ( http://github.com/2called-chaos/elch_scan/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
