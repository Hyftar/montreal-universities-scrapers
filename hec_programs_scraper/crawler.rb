require 'nokogiri'
require 'http'

# Gets all the programs from the HEC website and outsputs them in HTML format

# Don't ask me why, HEC just loads EVERYTHING in a single web page even if
# they have a paging system. This is good for us; less work.

open('data.html', 'w') do |io|
  io.puts Nokogiri::HTML(HTTP.get(URI("http://www.hec.ca/programmes/index.html")).to_s)
    .css('.PF_ProgItem')
    .map(&:parent)
end
