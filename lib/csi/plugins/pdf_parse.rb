# frozen_string_literal: true
require 'pdf-reader'

module CSI
  module Plugins
    # This plugin is used for parsing and interacting with PDF files
    module PDFParse
      # Supported Method Parameters::
      # CSI::Plugins::PDFParse.read_text(
      #   :pdf_path => 'optional path to dir defaults to .'
      # )

      public

      def self.read_text(opts = {})
        pdf_path = opts[:pdf_path].to_s.scrub if File.exists?(opts[:pdf_path].to_s.scrub)
        raise "CSI Error: Invalid Directory #{pdf_path}" if pdf_path.nil?

        begin
          pdf_pages_hash = {}
          page_no = 1
          reader = PDF::Reader.new(pdf_path)
          reader.pages.each do |page|
            print '.'
            pdf_pages_hash[page_no] = page.text
            page_no += 1
          end
          print "\n"
          return pdf_pages_hash
        rescue => e
          return e.message
        end
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
          pdf_pages_hash = #{self}.read_text(:pdf_path => 'required path to pdf file')

          #{self}.authors
        "
      end
    end
  end
end
