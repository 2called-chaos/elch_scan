require "pathname"
require "yaml"
require "find"
require "optparse"
require "tempfile"
require "bundler"
require "securerandom"

require "pry"
require "streamio-ffmpeg"
require "xmlsimple"
require "active_support/core_ext"
require "active_support/number_helper/number_converter"
require "active_support/number_helper/number_to_rounded_converter"
require "active_support/number_helper/number_to_delimited_converter"
require "active_support/number_helper/number_to_human_size_converter"

require "banana/logger"
require "elch_scan/version"
require "elch_scan/movie"
require "elch_scan/formatter/base"
require "elch_scan/formatter/plain"
require "elch_scan/formatter/html"
require "elch_scan/application/dispatch"
require "elch_scan/application/filter"
require "elch_scan/application"

module ElchScan
  I18n.enforce_available_locales = false
  ROOT = Pathname.new(File.expand_path("../..", __FILE__))
end
