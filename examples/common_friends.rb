$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'collectinject'

# Based on input graph of friendships ("'A' is a friend with 'B', 'C' and 'D'"),
# calculates common friends ("'A' and 'B' both has friends 'C' and 'D' in common").
# Idea and examples taken from http://stevekrenzel.com/finding-friends-with-mapreduce
class CommonFriendsWorker < CollectInject::WorkerBase
  # Output A's friend pairs, along with other friends of A
  def map_items items
    items.each do |me, friends|
      friends.each do |friend|
        map_emit [me, friend].sort, friends
      end
    end
  end

  # For every pair, gets friends in both lists:
  def reduce key, list
    [key, list.inject(&:&)]
  end
end

manager = CollectInject::Manager.new(CommonFriendsWorker, 3)
# Example taken from http://stevekrenzel.com/finding-friends-with-mapreduce
data = [
  [:A, [:B, :C, :D]],
  [:B, [:A, :C, :D, :E]],
  [:C, [:A, :B, :D, :E]],
  [:D, [:A, :B, :C, :E]],
  [:E, [:B, :C, :D]]
]
p manager.run(data)
#=> [[[:D, :E], [:B, :C]], [[:B, :E], [:C, :D]], [[:C, :E], [:B, :D]], [[:A, :B], [:C, :D]], [[:B, :D], [:A, :C, :E]], [[:B, :C], [:A, :D, :E]], [[:A, :C], [:B, :D]], [[:A, :D], [:B, :C]], [[:C, :D], [:A, :B, :E]]]
