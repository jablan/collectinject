$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'collectinject'

# A simple example of collectinject worker class which does
# guess what - counts frequency of characters in a given string
class LetterCountWorker < CollectInject::WorkerBase
  # map receives a letter and assigns it 1
  def map letter
    [letter, 1]
  end

  # sums count of appearances of certain character
  def reduce key, list
    [key, list.flatten.inject(&:+)]
  end
end

manager = CollectInject::Manager.new(LetterCountWorker, 3)
data = 'The quick brown fox jumps over the lazy dog'.chars
p manager.run(data)
#=> [["i", 1], ["o", 4], ["s", 1], ["e", 3], ["h", 2], ["w", 1], ["f", 1], ["m", 1], ["t", 1], ["d", 1], ["k", 1], ["r", 2], ["j", 1], ["T", 1], [" ", 8], ["x", 1], ["a", 1], ["q", 1], ["b", 1], ["z", 1], ["p", 1], ["u", 2], ["v", 1], ["g", 1], ["c", 1], ["n", 1], ["l", 1], ["y", 1]]
