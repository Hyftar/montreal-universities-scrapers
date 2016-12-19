require 'nokogiri'
require 'json'

# Parses the UdeM programs webpage to scrape its data and outputs it in the JSON format

class ProgrammeEtude

  attr_reader :title, :credits, :level, :number, :school, :url

  def initialize(title, credits, level, number, url)
    @title = title
    @credits = credits
    @level = level
    @number = number
    @url = url
    @school = 'Université de Montréal'
  end

  def to_hash
    {
      "title" => self.title,
      "credits" => self.credits,
      "level" => self.level,
      "number" => self.number,
      "school" => self.school,
      "url" => "https://admission.umontreal.ca#{self.url}",
    }
  end

  def to_s
    "#{self.title}, #{self.level}, #{self.number}, #{self.credits}"
  end
end

page = Nokogiri::HTML(File.open("data.html", "r").read) # Generated from crawler.rb
programs = page
  .css('div[class="programmeEtude"]')
  .map do |x|
    title = x.css('p[class="programmeEtudeTitle"]').text.strip
    attributes = x.css('span').text
    credits = attributes[/\d+[[:space:]]+crédits/] || title[/\d+[[:space:]]+crédits/] || 'none'
    number = attributes[/\d{1,2}-\d+-\d+-\d+/] || 'none'
    ProgrammeEtude.new(
      title,
      credits,
      x.css('span')[0].text, # level
      number,
      x.css('p[class="programmeEtudeTitle"] > a')[0]['href'] # url
    )
  end
  .map{|x| x.to_hash}

open('programs.json', 'w') { |io|
  io.puts JSON.pretty_generate(programs)
}
