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
    list.inject(&:+)
  end
end

manager = CollectInject::Manager.new(LetterCountWorker, 3)
data = 'The quick brown fox jumps over the lazy dog'.chars
p manager.run(data)
