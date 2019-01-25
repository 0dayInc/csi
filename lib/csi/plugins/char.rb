# frozen_string_literal: true

require 'cgi'
require 'htmlentities'

module CSI
  module Plugins
    # This plugin was created to generate various characters for fuzzing
    module Char
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::Plugins::Char.generate_by_range(
      #   from: 'required - integer to start from',
      #   to: 'required - integer to end UTF-8 generation'
      # )

      public_class_method def self.generate_by_range(opts = {})
        from = opts[:from].to_i
        to = opts[:to].to_i

        char_arr = []

        encoder_list_arr = list_encoders

        (from..to).each do |i|
          char_hash = {}

          this_bin = format('%08d', i.to_s(2))
          this_dec = i
          this_hex = format('%02x', i)
          this_long_int = [i].pack('L>').unpack1('H*').scan(/../).map { |h| '\x' + h }.join
          this_oct = format('\%03d', i.to_s(8))
          this_short_int = [i].pack('S>').unpack1('H*').scan(/../).map { |h| '\x' + h }.join
          this_utf8 = [i].pack('U*')

          this_html_entity = HTMLEntities.new.encode(this_utf8)
          this_html_entity_dec = HTMLEntities.new.encode(this_utf8, :decimal)
          this_html_entity_hex = HTMLEntities.new.encode(this_utf8, :hexadecimal)
          this_url = CGI.escape(this_utf8)

          # To date Base 2 - Base 36 is supported:
          # (0..999).each {|base| begin; puts "#{base} => #{this_dec.to_s(base)}"; rescue; next; end }
          char_hash[:bin] = this_bin
          char_hash[:dec] = this_dec
          char_hash[:hex] = this_hex
          char_hash[:html_entity] = this_html_entity
          char_hash[:html_entity_dec] = this_html_entity_dec
          char_hash[:html_entity_hex] = this_html_entity_hex
          char_hash[:long_int] = this_long_int
          char_hash[:oct] = this_oct
          char_hash[:short_int] = this_short_int
          char_hash[:utf8] = this_utf8
          char_hash[:url] = this_url

          encoder_list_arr.each do |encoder|
            this_encoder_key = encoder.downcase.tr('-', '_').to_sym
            begin
              char_hash[this_encoder_key] = this_utf8.encode(encoder, 'UTF-8')
            rescue
              char_hash[this_encoder_key] = nil
              next
            end
          end

          char_arr.push(char_hash)
        end

        return char_arr
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.c0_controls_latin_basic

      public_class_method def self.c0_controls_latin_basic
        char_hash = generate_by_range(from: 0, to: 127)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.c1_controls_latin_supplement

      public_class_method def self.c1_controls_latin_supplement
        char_hash = generate_by_range(from: 128, to: 255)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.latin_extended_a

      public_class_method def self.latin_extended_a
        char_hash = generate_by_range(from: 256, to: 383)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.latin_extended_b

      public_class_method def self.latin_extended_b
        char_hash = generate_by_range(from: 384, to: 591)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.spacing_modifiers

      public_class_method def self.spacing_modifiers
        char_hash = generate_by_range(from: 688, to: 767)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.diacritical_marks

      public_class_method def self.diacritical_marks
        char_hash = generate_by_range(from: 768, to: 879)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.greek_coptic

      public_class_method def self.greek_coptic
        char_hash = generate_by_range(from: 880, to: 1023)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.cyrillic_basic

      public_class_method def self.cyrillic_basic
        char_hash = generate_by_range(from: 1024, to: 1279)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.cyrillic_supplement

      public_class_method def self.cyrillic_supplement
        char_hash = generate_by_range(from: 1280, to: 1327)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.punctuation

      public_class_method def self.punctuation
        char_hash = generate_by_range(from: 8192, to: 8303)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.currency_symbols

      public_class_method def self.currency_symbols
        char_hash = generate_by_range(from: 8352, to: 8399)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.letterlike_symbols

      public_class_method def self.letterlike_symbols
        char_hash = generate_by_range(from: 8448, to: 8527)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.arrows

      public_class_method def self.arrows
        char_hash = generate_by_range(from: 8592, to: 8703)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.math_operators

      public_class_method def self.math_operators
        char_hash = generate_by_range(from: 8704, to: 8959)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.box_drawings

      public_class_method def self.box_drawings
        char_hash = generate_by_range(from: 9312, to: 9599)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.block_elements

      public_class_method def self.block_elements
        char_hash = generate_by_range(from: 9600, to: 9631)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.geometric_shapes

      public_class_method def self.geometric_shapes
        char_hash = generate_by_range(from: 9632, to: 9727)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.misc_symbols

      public_class_method def self.misc_symbols
        char_hash = generate_by_range(from: 9728, to: 9983)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.dingbats

      public_class_method def self.dingbats
        char_hash = generate_by_range(from: 9984, to: 10_175)

        char_hash
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.bubble_ip(
      #   ip: 'required - ip address to transform'
      # )

      public_class_method def self.bubble_ip(opts = {})
        ip = opts[:ip].to_s

        bubble_ip = ''
        ip_arr = ip.split('.')
        dot = "\u3002"
        ip_arr.each.with_index do |octet_str, this_index|
          octet_str.each_char do |digit_str|
            case digit_str.to_i
            when 0
              bubble_ip = "#{bubble_ip}\u24ea"
            when 1
              bubble_ip = "#{bubble_ip}\u2460"
            when 2
              bubble_ip = "#{bubble_ip}\u2461"
            when 3
              bubble_ip = "#{bubble_ip}\u2462"
            when 4
              bubble_ip = "#{bubble_ip}\u2463"
            when 5
              bubble_ip = "#{bubble_ip}\u2464"
            when 6
              bubble_ip = "#{bubble_ip}\u2465"
            when 7
              bubble_ip = "#{bubble_ip}\u2466"
            when 8
              bubble_ip = "#{bubble_ip}\u2467"
            when 9
              bubble_ip = "#{bubble_ip}\u2468"
            end
          end
          bubble_ip = "#{bubble_ip}#{dot}" if (this_index + 1) < ip_arr.length
        end

        return bubble_ip
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Char.list_encoders

      public_class_method def self.list_encoders
        encoder_arr = []

        Encoding.list.each do |encoder|
          encoder_arr.push(encoder.name)
        end

        return encoder_arr
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          char_arr = #{self}.generate_by_range(
            from: 'required - integer to start from',
            to: 'required - integer to end char generation'
          )

          #{self}.c0_controls_latin_basic

          #{self}.c1_controls_latin_supplement

          #{self}.latin_extended_a

          #{self}.latin_extended_b

          #{self}.spacing_modifiers

          #{self}.diacritical_marks

          #{self}.greek_coptic

          #{self}.cyrillic_basic

          #{self}.cyrillic_supplement

          #{self}.punctuation

          #{self}.currency_symbols

          #{self}.letterlike_symbols

          #{self}.arrows

          #{self}.math_operators

          #{self}.box_drawings

          #{self}.block_elements

          #{self}.geometric_shapes

          #{self}.misc_symbols

          #{self}.dingbats

          #{self}.bubble_ip(
            ip: 'required - ip address to transform'
          )

          #{self}.list_encoders

          #{self}.authors
        "
      end
    end
  end
end
