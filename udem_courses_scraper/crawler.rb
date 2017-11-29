require 'https'
require 'thread'


# Gets all the courses from the UdeM website and outputs them in HTML format
# AFAIK, there's no easier way to do this since you need to make requests to the
# server and there's no way to know how many pages there are.

def get_next_uri
  uri = URI("https://admission.umontreal.ca/repertoire-des-cours/?type=888&tx_solr[page]=#{@i}&_=1482099640247")
  @i += 1
  return uri
end

def get_courses(uri)
  content = HTTP.get(uri).to_s
  @is_writing.lock
  File.open('data.html', 'a') { |f| f.puts content }
  @is_writing.unlock
  return content
end


@i = 0
@num_of_threads = 20
@is_writing = Mutex.new

threads = []

@num_of_threads.times do
  threads << Thread.new do
    loop do
      break if get_courses(get_next_uri).size < 100
      print '.'
    end
  end
end

threads.each { |thr| thr.join }
