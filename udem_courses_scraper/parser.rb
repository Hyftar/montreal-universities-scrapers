require 'nokogiri'
require 'json'

# Parses the data from data.html into JSON format
# Execute crawler.rb first to generate the data file

class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = "https://admission.umontreal.ca/#{url}"
    @credits = credits
    @school = 'Université de Montréal'
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

courses = Nokogiri::HTML(File.open('data.html', 'r').read)
  .css('tr')[1..-1]
  .map do |x|
    Course.new(
      x.css('p[class="programmeEtudeTitle"]').css('a').text,
      x.css('td[class="cours-numero"]').css('span').text,
      x.css('p[class="programmeEtudeTitle"]').css('a')[0]['href'],
      x.css('td').css('span')[-1].text.match(/(\d+\.\d+)/)[1].to_f,
    )
  end
  .map(&:to_hash)

open('courses_fr.json', 'w') do |io|
  io.puts JSON.generate(courses)
end
