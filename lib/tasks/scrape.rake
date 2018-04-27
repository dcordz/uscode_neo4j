require 'pry'
require 'json'
require 'colorize'

desc "Parse json input uscode into levels"
task :scrape => :environment do

  initial_page = "https://www.law.cornell.edu/uscode/text"
  init = Nokogiri::HTML(HTTParty.get(initial_page))
  binding.pry

end
