require "bundler"
Bundler.require(:default)
require "elch_scan"

ElchScan::Application.dispatch(ENV, ARGV)
