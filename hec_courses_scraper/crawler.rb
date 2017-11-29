# Before executing this script, copy the programs_urls.txt, generated from
# the HEC programs scraper, here.

require 'http'
require 'parallel'
require 'nokogiri'
require 'thread'

@is_writing = Mutex.new

# Gets all the URLs from programs_urls.txt
urls = []
File.foreach("programs_urls.txt") { |line| urls << URI(line.strip.gsub('index.html', 'structure/index.html')) }

Parallel.each(urls, in_threads: 25) do |url|
  if url.to_s =~ /hec\.ca/ # Some programs link to other websites
    courses_html = Nokogiri::HTML(HTTP.get(url).to_s).css('.CoursRow')
    @is_writing.lock
    File.open('data.html', 'a') do |io|
      io.puts courses_html
    end
    @is_writing.unlock
  end
end
