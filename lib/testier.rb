require 'lib/wikier'
require 'lib/cellwikier'
require 'lib/poolier'

class Testier
  
  # Standard list of words to get from Wikipedia
  def words
    %w(
    Texas Ruby Dallas Brigade Physics Dairy Beer
    England Scotland Lamp Trophy Aspertame Diagram
    Scoville Feynman Traffic Motorcycle Florida Barrier
    )
  end

  # DRY Time
  def curr_time
    Time.now.strftime("%H:%M:%S")
  end

  # Builder for counters for each letter
  def empty_counter
    counts = {}
    ('a'..'z').each {|letter| counts[letter] = 0}
    counts
  end

  # Compress array of hashes to single hash of letter counts
  def count_results(result_array)
    results = empty_counter
    result_array.each do |topic|
      topic.keys.each {|key| results[key] += topic[key]}
    end
    results
  end

  # Do each word the standard way, one at a time
  def linear(test_words = words)
    start_time = Time.now
    puts "Linear Test"
    puts curr_time
    puts "------------------"
    results = []
    test_words.each do |word|
      linear_doer = Wikier.new
      results << linear_doer.process(word)
    end
    puts "------------------"
    puts "Finished: #{curr_time} - #{Time.now - start_time} secs"
    return count_results(results)
  end

  # Do each word in parallel
  def parallel(test_words = words)
    start_time = Time.now
    puts "Parallel test"
    puts curr_time
    puts "------------------"
    threads = []
    test_words.each {|word| threads << CellWikier.new.future.process(word)}
    puts "#{threads.count}Threads started"
    results = threads.map {|item| item.value}
    puts "------------------"
    puts "Finished: #{curr_time} - #{Time.now - start_time} secs"
    return count_results(results)
  end
  
  def pooly(workers, test_words = words)
    start_time = Time.now
    puts "#{workers} worker pooling test"
    puts curr_time
    puts "------------------"
    swimmyplace = CellWikier.pool(size: workers)
    # Passing the pool a block and getting back an array of workers
    swimmers = words.map do |word|
      # note that we use a symbol for the method
      swimmyplace.future(:process, word)
    end
    puts "Swimmers is an array of #{swimmers.first.inspect}"
    results = []
    swimmers.compact.each {|swimmer| results << swimmer.value }
    puts "------------------"
    puts "Finished: #{curr_time} - #{Time.now - start_time}"
    return count_results(results)
  end
  
  def linear_test
    puts linear().inspect
  end
  
  def pooly_test(treads)
    puts pooly(treads).inspect
  end
  
  def parallel_test
    puts parallel().inspect
  end
  
end


