require "elch_scan/version"
require "elch_scan/application"

module ElchScan
  require "pathname"
  ROOT = Pathname.new(File.expand_path("../..", __FILE__))
end
