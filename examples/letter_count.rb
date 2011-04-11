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
#=> {"T"=>1, "u"=>2, "h"=>2, "c"=>1, "z"=>1, "j"=>1, "l"=>1, "x"=>1, "a"=>1, "w"=>1, "f"=>1, "m"=>1, "t"=>1, "d"=>1, "k"=>1, "r"=>2, "y"=>1, " "=>8, "i"=>1, "o"=>4, "s"=>1, "v"=>1, "e"=>3, "g"=>1, "q"=>1, "b"=>1, "n"=>1, "p"=>1}
