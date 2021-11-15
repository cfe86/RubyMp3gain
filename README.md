# RubyMp3gain

RubyMP3Gain is an [Mp3Gain](http://mp3gain.sourceforge.net/) wrapper written in Ruby. Works also with e.g. [aacgain](https://formulae.brew.sh/formula/aacgain) for Mac OSX.

## Installation

from [rubygems](https://rubygems.org/gems/mp3gain) using
```shell
gem install mp3gain
```
or from the sources using
```shell
gem build mp3gain.gemspec
```
And then execute:
```shell
$ gem install mp3gain-1.0.0.gem
```

## Usage

```ruby
require 'mp3gain'
mp3gain = Mp3gain.init("path/to/MP3Gain/binary")
## optional target db and preserve timestamps
mp3gain = Mp3gain.init("aacgain", 100, preserve_timestamp: false)

# print current version
mp3gain.version 
# analyze the gain of the given files
mp3gain.analyze_gain(['path/to/file1', 'path/to/file2'])
# delete stored tag infos of the given files
mp3gain.delete_stored_tag_info(['path/to/file1', 'path/to/file2'])
# apply track gain depending on the provided target DB
mp3gain.apply_track_gain(['path/to/file1', 'path/to/file2'])
# apply album gain depending on the provided target DB
mp3gain.apply_album_gain(['path/to/file1', 'path/to/file2'])
# apply the given gain 
mp3gain.add_gain(['path/to/file1', 'path/to/file2'], 5)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
