require 'https'
require 'thread'


# Gets all the programs from the UdeM website and outputs them in HTML format

# AFAIK, there's no easier way to do this since you need to make requests to the
# server and there's no way to know how many pages there are.

# This is the base URL used for requests:
# https://admission.umontreal.ca/programmes-detudes/?type=888&tx_solr[page]=0&_=1482177335727
# You can use the English URL if needed, but the links to programs pages are still in French
# so in the end it doesn't really matter.

def get_next_uri
  @is_getting_uri.lock
  uri = URI("https://admission.umontreal.ca/programmes-detudes/?type=888&tx_solr[page]=#{@i}&_=1482177335727")
  @i += 1
  @is_getting_uri.unlock
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

# Those mutex are here to prevent race conditions
# when getting new URI or writing to the file
@is_writing = Mutex.new
@is_getting_uri = Mutex.new

threads = []

@num_of_threads.times do
  threads << Thread.new do
    loop do
      break if get_courses(get_next_uri).size < 100
      print '.' # This is just to have an idea of the crawler's speed
    end
  end
end

threads.each { |thr| thr.join }
