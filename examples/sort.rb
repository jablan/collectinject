$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'collectinject'

# A simple example of collectinject worker class which sorts
# characters from a given input string
# Sorting alorithm is simple: divide input array into chunks,
# use +sort+ to sort each chunk separately in map phase,
# and merge the sorted chunks in reduce phase.
class SortWorker < CollectInject::WorkerBase
  # map_items receives a chunk of items and simply sorts it using Array#sort
  def map_items items
    items.sort.each do |item|
      map_emit 1, item
    end
  end

  # reduce merges sorted arrays into one resulting array, observing order
  def reduce key, list
    res = []
    loop do
      min = list.reject(&:empty?).min # find array starting with smallest element
      break if min.nil? # break if none found
      res << min.shift # pull out the first element and append it to result
    end
    res
  end
end

manager = CollectInject::Manager.new(SortWorker, 3)
data = 'The quick brown fox jumps over the lazy dog'.chars
p manager.run(data)
#=> [[" ", " ", " ", " ", " ", " ", " ", " ", "T", "a", "b", "c", "d", "e", "e", "e", "f", "g", "h", "h", "i", "j", "k", "l", "m", "n", "o", "o", "o", "o", "p", "q", "r", "r", "s", "t", "u", "u", "v", "w", "x", "y", "z"]]

