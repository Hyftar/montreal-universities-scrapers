require 'http'
require 'nokogiri'
require 'json'
require 'parallel'
require 'irb'


class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = url
    @credits = credits
    @school = 'Université McGill'
  end

  def to_hash
    {
      "title" => self.title,
      "url" => "http://www.mcgill.ca/#{self.url}",
      "number" => self.number,
      "credits" => self.credits,
      "school" => self.school,
    }
  end
end

def get_uri(index)
  URI("http://www.mcgill.ca/study/2016-2017/courses/search?search_api_views_fulltext=&sort_by=field_subject_code&page=#{index}")
end


courses = Parallel.map(0..506, in_threads: 30, progress: 'Getting courses info') do |index|
# courses = (0..506).map do |index|
  Nokogiri::HTML(HTTP.get(get_uri(index)).to_s)
    .css('div.views-field > h4 > a')
    .map do |row|
      binding.irb if (!row.text.match?(/\w+ \w+ (.+) \(\d+\.?\d* c/) || !row.text.match?(/(\w+ \w+)/) || row.text.match?(/\(\d+\.?\d*\)/))
      Course.new(
        row.text.match(/\w+ \w+ (.+) \(\d+\.?\d* c/)[1],
        row.text.match(/(\w+ \w+)/)[1],
        row['href'],
        row.text.match(/\((\d+\.?\d*) c/)[1].to_f
      )
    end
end.flatten

File.open('courses.json', 'w') do |io|
  io.puts JSON.generate(courses.map(&:to_hash))
end
