require 'nokogiri'
require 'json'


class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = "https://admission.umontreal.ca/#{url}"
    @credits = credits
    @school = 'HEC Montréal'
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

class Program
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = url
    @credits = credits
    @school = 'HEC Montréal'
  end

  def to_s
    "#{self.title}, #{self.number}, #{self.credits}, #{self.url}"
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
programs = Nokogiri::HTML(File.open('data.html', 'r').read)
  .css('a')
  .map do |x|
    Program.new(
      x.css('h3').text.strip,
      'none', # Info missing on the website
      x['href'].strip,
      x.css('.PF_ProgItemInfoText').text.match(/\d+/).to_s.to_f,
    )
  end
  .map(&:to_hash)

open('programs.json', 'w') do |io|
  io.puts JSON::generate(programs)
end
