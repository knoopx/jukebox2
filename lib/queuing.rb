require "thread"

module Rails
  class Application
    attr_accessor :queue, :queue_consumer
  end

  class << self
    delegate :queue, :queue_consumer, :to => :application
  end
end

module Queueing
  class Railtie < Rails::Railtie
    initializer :activate_queue_consumer do |app|
      puts "Starting queue"
      app.queue = Queue.new
      unless Rails.env.test?
        app.queue_consumer = ThreadedConsumer.start(app.queue)
        at_exit { app.queue_consumer.shutdown }
      end
    end
  end

  class Queue < ::Queue
    def push(obj = nil, &block)
      if block_given?
        super(block)
      else
        super(obj)
      end
    end
  end

  class ThreadedConsumer
    def self.start(queue)
      new(queue).start
    end

    def initialize(queue)
      @queue = queue
    end

    def start
      @threads = 5.times.map do
        Thread.new do
          while job = @queue.pop
            begin
              job.call
            rescue Exception => e
              handle_exception e
            end
          end
        end
      end
      self
    end

    def shutdown
      @queue.push nil
      @threads.map(&:join)
    end

    def handle_exception(e)
      Rails.logger.error "Job Error: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
