require 'wikipedia'

class Wikier

  def process(topic)
    puts "Processing: #{topic}"
    rv = {}
    content_base = Wikipedia.find(topic)
    content = content_base.content.downcase
    interesting_letters.each {|letter| rv[letter] = content.count(letter)}
    rv
  end
  
  def interesting_letters
    ('a'..'z')
  end
  
end