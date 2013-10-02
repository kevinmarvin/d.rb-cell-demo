require 'wikipedia'
require 'celluloid'

class Poolier
  
  include Celluloid
  
  
  def process(topic)
    puts "Processing: #{topic}"
    rv = {}
    content = Wikipedia.find(topic).content.downcase
    interesting_letters.each {|letter| rv[letter] = content.count(letter)}
    rv
  end
  
  def interesting_letters
    ('a'..'z')
  end
  
end
