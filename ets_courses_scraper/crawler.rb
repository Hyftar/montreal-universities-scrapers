require 'net/https'
require 'thread'
require 'nokogiri'
require 'parallel'

# Gets all the courses from the ÉTS website and outputs them in HTML format


def get_courses(uri)
  Nokogiri::HTML(Net::HTTP.get(uri))
    .css('#plc_lt_zoneMain_pageplaceholder_pageplaceholder_lt_zoneContent_pageplaceholder_pageplaceholder_lt_zoneCenter_pageplaceholder_pageplaceholder_lt_zoneCenter_ListeCoursParTitre_GridViewResultats')
end

uris = Enumerator.new do |yielder|
  ('a'..'z').each do |c|
    yielder << URI("https://www.etsmtl.ca/Etudiants-actuels/Baccalaureat/Cours-horaires-1er-cycle/Cours-par-titre?lettre=#{c}")
    yielder << URI("https://www.etsmtl.ca/Etudiants-actuels/Cycles-sup/Cours-horaires-cycles-sup/Cours-par-titre?lettre=#{c}")
    yielder << URI("https://www.etsmtl.ca/Etudiants-actuels/Cheminement-univ-techno/Cours-horaires-chem-univ/Cours-par-titre?lettre=#{c}")
    yielder << URI("https://www.etsmtl.ca/Etudiants-actuels/Certificat-prog-court-1er-cycle/Cours-horaires-1er-cycle/Cours-par-titre?lettre=#{c}")
  end
end

is_writing = Mutex.new

Parallel.each(uris, progress: "Getting courses HTML pages", in_threads: 30) do |uri|
  content = get_courses(uri)
  is_writing.lock
  File.open('data.html', 'a') do |io|
    io.puts content
  end
  is_writing.unlock
end
