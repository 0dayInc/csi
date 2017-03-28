# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin makes the creation of a thread pool much simpler.
    module ThreadPool
      # Supported Method Parameters::
      # CSI::Plugins::ThreadPool.fill(
      #   enumerable_array: 'required array for proper thread pool assignment',
      #   :max_threads: 'optional number of threads in the thread pool (defaults to 6)',
      #   &block
      # )
      #
      # Example: #{self}.fill(enumerable_array: arr_test_cases, max_threads: 99) do |test_case|
      #            print test_case
      #            sleep 3
      #            # <do more stuff>
      #          end

      public

      # def self.fill(opts = {}, &block)
      def self.fill(opts = {})
        enumerable_array = opts[:enumerable_array]

        max_threads = if opts[:max_threads].nil?
                        9
                      else
                        opts[:max_threads].to_i
                      end

        puts "Initiating Thread Pool of #{max_threads} Worker Threads...."
        queue = SizedQueue.new(max_threads)
        threads = Array.new(max_threads) do
          Thread.new do
            until (test_case = queue.pop) == :END
              # block.call(test_case)
              yield test_case
            end
          end
        end
        enumerable_array.uniq.sort.each { |test_case| queue << test_case }
        max_threads.times { queue << :END }
        threads.each(&:join)
      rescue => e
        raise e.message
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          #{self}.fill(
            enumerable_array. => 'required array for proper thread pool assignment',
            max_threads: 'optional number of threads in the thread pool (defaults to 6)',
            &block
          )
          Example: #{self}.fill(enumerable_array: arr_ips, max_threads: 99) do |ip|
                     `nmap -Pn -p 22 #\{ip\}`
                   end

          #{self}.authors
        "
      end
    end
  end
end
