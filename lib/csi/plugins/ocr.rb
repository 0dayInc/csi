# frozen_string_literal: true

require 'rtesseract'

module CSI
  module Plugins
    # This plugin processes images into readable text
    module OCR
      # Supported Method Parameters::
      # CSI::Plugins::OCR.process(
      #   file: 'required - path to image file',
      # )

      public_class_method def self.process(opts = {})
        file = opts[:file].to_s.scrub.strip.chomp if File.exist?(opts[:file].to_s.scrub.strip.chomp)
        image = RTesseract.new(file)
        image.to_s
      rescue StandardError => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          #{self}.process(
            file: 'required - path to image file'
          )

          #{self}.authors
        "
      end
    end
  end
end
