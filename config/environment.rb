#require 'require_all'
require 'bundler'
require 'pry'
require 'nokogiri'
require 'open-uri'
Bundler.require

#require_all 'lib'
require_relative "../lib/change.rb"
require_relative "../lib/command_line_interface.rb"
require_relative "../lib/command.rb"
require_relative "../lib/entertainment_product.rb"
require_relative "../lib/scraper.rb"
