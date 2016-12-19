require 'net/https'
require 'thread'
require 'nokogiri'

# Gets all the courses from the ÉTS website and outputs them in HTML format

def get_next_uri
  uri = URI("https://www.etsmtl.ca/Etudiants-actuels/Baccalaureat/Cours-horaires-1er-cycle/Cours-par-titre?lettre=#{@l}")
  @l = @l.next
  return uri
end

def get_courses(uri)
  Net::HTTP.get(uri)
end

@l = 'a'
@num_of_threads = 26
@is_writing = Mutex.new

threads = []

@num_of_threads.times {
  threads << Thread.new {
    until @l > 'z' do
      uri = get_next_uri
      @is_writing.lock
      File.open('data.html', 'a') { |io|
        io.puts Nokogiri::HTML(
          get_courses(uri))
            .css('#plc_lt_zoneMain_pageplaceholder_pageplaceholder_lt_zoneContent_pageplaceholder_pageplaceholder_lt_zoneCenter_pageplaceholder_pageplaceholder_lt_zoneCenter_ListeCoursParTitre_GridViewResultats')
            # Why the fuck is this ID so long?!
      }
      @is_writing.unlock
    end
  }
}

threads.each { |thr| thr.join }
