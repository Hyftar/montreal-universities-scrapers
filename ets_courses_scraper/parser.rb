require 'nokogiri'
require 'json'
require 'parallel'
require 'http'


# Parses the data from data.html into JSON format
# Execute crawler.rb first to generate the data file

class Course
  attr_accessor :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = "https://www.etsmtl.ca/Etudiants-actuels/Baccalaureat/Cours-horaires-1er-cycle/#{url}"
    @credits = credits
    @school = 'École de technologie supérieure'
  end

  def to_s
    "#{title}, #{number}, #{credits}, #{url}"
  end

  def to_hash
    {
      "title" => self.title,
      "url" => self.url,
      "number" => self.number,
      "credits" => self.credits,
      "school" => self.school
    }
  end
end

courses = Nokogiri::HTML(File.open('data.html', 'r').read)

courses_html =
  courses.css('tr[class="GrilleRowImpair"]') +
  courses.css('tr[class="GrilleRowPair"]')


courses_objects =
  courses_html
    .map { |x|
      Course.new(
        x.css('td[class="ListeCoursGrilleCol2"]').text.strip,
        x.css('td[class="ListeCoursGrilleCol1"]').css('a').text,
        x.css('td[class="ListeCoursGrilleCol1"]').css('a')[0]['href'],
        0 # Placeholder
      )
    }

courses_objects.uniq! { |c| c.number }

puts "Number of courses found: #{courses_objects.size}"

Parallel.each(courses_objects, progress: "Getting courses credits", in_threads: 20) do |course|
  page = HTTP.get(URI(course.url)).to_s
  credits_span =
    Nokogiri::HTML(page)
      .css('span#plc_lt_zoneMain_pageplaceholder_pageplaceholder_lt_zoneRight_FicheCoursInfosDroite_LabelCredits')
      .text
      .match(/(\d+(?:[.,]\d+)?)/)

  course.credits = credits_span ? credits_span.captures.first.to_f : 0
end

open('courses_fr.json', 'w') do |io|
  io.puts JSON.generate(
    courses_objects
      .map(&:to_hash)
  )
end
