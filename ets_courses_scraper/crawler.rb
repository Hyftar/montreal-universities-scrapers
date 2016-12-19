require 'net/https'
require 'thread'
require 'nokogiri'

# Gets all the courses from the ÉTS website and outputs them in HTML format

def get_next_uri
  URI("https://www.etsmtl.ca/Etudiants-actuels/Baccalaureat/Cours-horaires-1er-cycle/Cours-par-titre?lettre=#{@letters.pop}")
end

def get_courses(uri)
  Net::HTTP.get(uri)
end

@letters = ('a'..'z').to_a
@num_of_threads = 26
@is_writing = Mutex.new

threads = []

@num_of_threads.times {
  threads << Thread.new {
    until @letters.empty? do
      content = get_courses(get_next_uri)
      @is_writing.lock
      File.open('data.html', 'a') { |io|
        io.puts Nokogiri::HTML(content)
            .css('#plc_lt_zoneMain_pageplaceholder_pageplaceholder_lt_zoneContent_pageplaceholder_pageplaceholder_lt_zoneCenter_pageplaceholder_pageplaceholder_lt_zoneCenter_ListeCoursParTitre_GridViewResultats')
            # Why the fuck is this ID so long?!
      }
      @is_writing.unlock
    end
  }
}

threads.each { |thr| thr.join }
