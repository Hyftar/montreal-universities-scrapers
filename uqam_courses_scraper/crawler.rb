require 'net/http'
require 'json'
require 'parallel'
require 'nokogiri'
require 'irb'


class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = url
    @credits = credits
    @school = 'Université du Québec à Montréal'
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


# Getting the urls of every field of study
fields_list_urls =
  Nokogiri::HTML(Net::HTTP.get(URI('https://etudier.uqam.ca/cours-par-discipline')))
    .css('table')
    .css('a')
    .map { |e| "https://etudier.uqam.ca/#{e['href']}" }

# This will contain hashes of courses with titles and urls
courses_urls = []

Parallel.each(fields_list_urls, in_threads: 30, progress: 'Getting courses urls and titles') do |url|
# fields_list_urls.each do |url| # Syncronous version (VERY slow)
  courses_list_page =
    Nokogiri::HTML(Net::HTTP.get(URI(url)))

  next if courses_list_page.css('#tableCours').empty?
  courses_urls <<
    courses_list_page
      .css('#tableCours')
      .css('tr')[1..-1]
      .map do |row|
        columns = row.children
        {
          title: columns[1].text,
          url: "https://etudier.uqam.ca/#{columns.first.children.first['href']}",
          number: columns.first.children.first.text,
        }
      end
end

# We remove the nested arrays and the duplicates
courses_urls.flatten!.uniq!

# Let's also get the credits for each course because I hate myself..

courses = Parallel.map(courses_urls, in_threads: 30, progress: 'Getting courses credits') do |entry|
# courses_urls.map! do |entry|
  if Nokogiri::HTML(Net::HTTP.get(URI(entry[:url]))).css('.encadre > div:nth-child(1) > ul:nth-child(1) > li').text.match(/dits : (\d+\.?\d*)/)
    credits = $~[1].to_f
  else
    credits = 0.0
  end
  Course.new(
    entry[:title],
    entry[:number],
    entry[:url],
    credits
  )
end

File.open('courses.json', 'w') do |io|
  io.puts JSON.generate(courses.map(&:to_hash))
end
