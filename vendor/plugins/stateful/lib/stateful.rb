require 'rubygems'
require 'active_support'
require "#{File.dirname( __FILE__ )}/stateful/loader.rb"

# just load the library files for Stateful in an order they like.

Stateful::Loader.load!

# see the README for usage
