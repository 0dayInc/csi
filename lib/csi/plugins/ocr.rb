require 'ai4r' # Learn how to process harder-to-read images
require 'rtesseract'

module CSI
  module Plugins
    # This plugin processes images into readable text
    module OCR
      # Supported Method Parameters::
      # CSI::Plugins::OCR.process(
      #   :file => 'required - path to image file',
      # )
      public
      def self.process(opts={})
        file = opts[:file].to_s.scrub.strip.chomp if File.exists?(opts[:file].to_s.scrub.strip.chomp)
        image = RTesseract.new(file)
        text = image.to_s

        return text
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = %Q{AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        }

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          #{self}.process(
            :file => 'required - path to image file'
          )

          #{self}.authors
        }
      end
    end
  end
end
