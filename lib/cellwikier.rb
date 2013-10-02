require 'wikipedia'
require 'celluloid'

class CellWikier
  
  include Celluloid
  
  def process(topic)
    puts "Processing: #{topic}"
    rv = {}
    content_src = Wikipedia.find(topic)
    content = content_src.content.downcase
    interesting_letters.each {|letter| rv[letter] = content.count(letter)}
    rv
  end
  
  def interesting_letters
    ('a'..'z')
  end
  
end
