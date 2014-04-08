# TIP: Using vim and want to get rid of this example shit?
#      In nav-mode type: 100dd

# Hey there,
# to filter your records you will use Ruby
# but don't be afraid, it's fairly simple.
# Just look at the examples and referenced links.

# You have access to a variable `collection` and
# whatever you do with it, we will take the same
# variable `collection` as result.
# This means you can reassign or permute it.
# YOU SHOULD NOT MODIFY the movie objects! Do this
# with "-p" or "--permute"!

# Use ruby methods to narrow down you result set.
#   * http://www.ruby-doc.org/core-2.1.1/File.html
#   * http://www.ruby-doc.org/core-2.1.1/Enumerable.html

# ====================================================
# = Doc (remove, reuse or comment out the examples!) =
# ====================================================
collection.select! do |name, movie|
  # name is the same as movie.dirname
  # movie has the following methods
  #   * dir     => source movie directory (e.g. C:/Movies)
  #   * path    => folder path of movie (e.g. C:/Movies/BestFilmEver)
  #   * dirname => source movie directory name (e.g. BestFilmEver)
  #   * files   => array of all files in movie folder
  #   * name    => base name of movie file (without extension)
  #   * movie   => movie file
  #   * nfo!    => Hash/Array representation of NFO-XML (see http://xml-simple.rubyforge.org/)
  #                Almost all shit is an array so [0] or .first is your friend.
  #                Pass a block (yields the nfo representation) to catch nil[] errors.
  #   * source  => StreamIO object (see https://github.com/streamio/streamio-ffmpeg)
  #   * all naming key names from the configuration file (nfo, poster, etc.)

  # Set break point to interactively call methods from here.
  # See http://pryrepl.org ory type "help" when you are in the REPL.
  # Use exit or exit! to break out of REPL.
  # binding.pry
end

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

# No thriller movies
collection.select! do |name, movie|
  !movie.nfo!{|n| n["genre"][0].split("/").map(&:strip).include?("Thriller") }
end

# Only with english sound stream
collection.select! do |name, movie|
  movie.nfo! do |nfo|
    nfo["fileinfo"][0]["streamdetails"][0]["audio"].any? do |stream|
      stream["language"][0] == "eng"
    end
  end
end
