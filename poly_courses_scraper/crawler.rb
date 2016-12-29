require 'net/http'
require 'nokogiri'
require 'parallel'
require 'open-uri'
require 'openssl'
require 'json'


# This crawler does both the crawling and the parsing, because there isn't
# enough information on a single page on the Polytechnique website, you have
# to get the data on multiple pages and it's just easier to do both at once.

class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = url
    @credits = credits
    @school = 'Polytechnique Montréal'
  end

  def to_hash
    {
      "title" => self.title,
      "url" => self.url,
      "number" => self.number,
      "credits" => self.credits,
      "school" => self.school,
    }
  end
end

courses_urls =
  # Here we have to provide a User-Agent or else it returns a 403, forbidden. Doesn't make crawling any harder.
  Nokogiri::HTML(open("http://www.polymtl.ca/etudes/planTri/index.php", 'User-Agent' => 'firefox').read)
    .css('table')
    .map { |e| e.css('tr')[2..-1] }
    .compact
    .map do |t|
      t.css('a')
        .map do |e|
          {
            'title' => e.parent.parent.css('td')[1].text,
            'url' => e['href']
          }
        end
    end
    .flatten


courses = Parallel.map(courses_urls, in_threads: 25, progress: 'Getting courses information') do |course|
  info = Nokogiri::HTML(open(course['url'], 'User-Agent' => 'firefox').read)
  if info.css('h1').text =~ /Erreur/ # Some pages have errors in them.
    Course.new(course['title'], course['url'].match(/\?sigle=(.+)$/)[1], course['url'], 'none')
  else
    info = info
    .css('table')
    .css('tr')

    Course.new(
      course['title'],
      course['url'].match(/\?sigle=(.+)$/)[1], # it's easier to get the course number from the url than on the page.
      course['url'],
      info[1].children.last.text.strip.to_f,
    )
  end
end


File.open('courses.json', 'w') do |io|
  io.puts JSON.generate(courses.map(&:to_hash))
end
