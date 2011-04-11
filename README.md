# CollectInject - a tiny MapReduce implementation in Ruby

## Disclaimer:

Do _not_ use this in production. This project is purely for recreational and educational purposes. It was not written with either performance, stability and general usefullness in mind.

## Description:

Here's a shot on implementing simple [MapReduce](http://en.wikipedia.org/wiki/MapReduce) library in Ruby. I did it for practice, and thought it could be useful for introducing people to the whole concept of distributed processing.

CollectInject is not really distributed, it simulates this using threads, so each worker is started in separate thread.

Also, CollectInject works with data in-memory, no persistance, not intended for large datasets etc. It offers simple class `WorkerBase` with `map` and `reduce` methods which you should implement in your own worker class. There's also `Manager` class for actually running CollectInject tasks.

## Usage:

* `require 'collectinject'`
* create your own class by inheriting `WorkerBase`
* implement `map` and `reduce` (take look at examples)
* initialize `Manager` instance with your class and number of workers
* `run` manager with your dataset

Generally, check out `examples` directory, it should be fairly simple.

## Notes:

You are encouraged to fork and play with CollectInject, fix and improve the code, add your own examples, send me pull requests, questions and ideas etc. Have fun coding as much as I am! :)
