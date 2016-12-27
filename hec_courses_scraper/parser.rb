require 'nokogiri'
require 'json'
require 'net/http'


requests_urls = [
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=BAA,APRE',
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=CERT',
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=MBA',
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=DES',
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=MSCP,MSC',
  'https://zonecours2.hec.ca/direct/catalogDescription.json?career=PHDP,PHD',
]


class Course
  attr_reader :title, :number, :url, :credits, :school

  def initialize(title, number, url, credits)
    @title = title
    @number = number
    @url = url
    @credits = credits
    @school = 'HEC Montréal'
  end

  def to_s
    "#{self.title}, #{self.number} $ #{self.credits}"
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

File.open('courses.json', 'w') do |io|
  io.puts JSON.generate(
    requests_urls
      .map { |url| Net::HTTP.get(URI(url)) }
      .map { |data| JSON.parse(data) }
      .map { |x| x['catalogDescription_collection'] }
      .flatten
      .map do |elem|
        Course.new(
          elem['title'],
          elem['courseId'],
          "#{elem['entityURL']}/#{elem['courseId']}.json",
          elem['credits'].to_f
        )
      end
      .map(&:to_hash)
  )
end
