# frozen_string_literal: true
require 'htmlentities'
require 'socket'

module CSI
  module SCAPM
    # SCAPM Module used to identify whether
    # error messages are sanitized properly.
    module ThrowErrors

      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::SCAPM::ThrowErrors.scan(
      #   :dir_path => 'optional path to dir defaults to .'
      #   :git_repo_root_uri => 'optional http uri of git repo scanned'
      # )
      public
      def self.scan(opts = {})
        dir_path = opts[:dir_path]
        git_repo_root_uri = opts[:git_repo_root_uri].to_s.scrub
        result_arr = []
        logger_results = ''

        CSI::Plugins::FileFu.recurse_dir(dir_path: dir_path) do |entry|
          if ( File.file?(entry) && File.basename(entry) !~ /^csi.+(html|json|db)$/ && File.basename(entry) !~ /\.JS-BEAUTIFIED$/ ) && (File.extname(entry) == '.scala' || File.extname(entry) == '.java')
            line_no_and_contents_arr = []
            filename_arr = []
            test_case_filter = %Q{
              grep -in throw #{entry} | grep '"' 
            }

            str = HTMLEntities.new.encode(`#{test_case_filter}`.to_s.scrub)

            if str.to_s.length > 0
              # If str length is >= 64 KB do not include results. (Due to Mongo Document Size Restrictions)
              str = "1:Result larger than 64KB -> Size: #{str.to_s.length}.  Please click the \"Path\" link for more details." if str.to_s.length >= 64000

              hash_line = {
                timestamp: "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%9N %z')}", 
                test_case: self.nist_800_53_requirements, 
                filename: filename_arr.push({ git_repo_root_uri: git_repo_root_uri, entry: entry }),  
                line_no_and_contents: '', 
                raw_content: str, 
                test_case_filter: HTMLEntities.new.encode(test_case_filter)
              }

              # COMMMENT: Must be a better way to implement this (regex is kinda funky)
              line_contents_split = str.split(/^(\d{1,}):|\n(\d{1,}):/)[1..-1]
              line_no_count = line_contents_split.length # This should always be an even number
              current_count = 0
              while line_no_count > current_count
                line_no = line_contents_split[current_count]
                contents = line_contents_split[current_count + 1]
                author = HTMLEntities.new.encode(CSI::Plugins::Git.get_author_by_line_range(
                  repo_root: dir_path,
                  from_line: line_no, 
                  to_line: line_no, 
                  target_file: entry
                ))
                hash_line[:line_no_and_contents] = line_no_and_contents_arr.push({
                  line_no: line_no, 
                  contents: contents,
                  author: author
                })

                current_count+=2 
              end
              result_arr.push(hash_line)
              logger_results << 'x' # Catching bugs is good :)
            else
              logger_results << '~' # Seeing progress is good :)
            end
          end
        end
         logger_banner = "http://#{Socket.gethostname}:8808/doc_root/csi-#{CSI::VERSION.to_s.scrub}/#{self.to_s.scrub.gsub('::', '/')}.html"
        if logger_results.empty?
          @@logger.info("#{logger_banner}: No files applicable to this test case.\n")
        else
          @@logger.info("#{logger_banner} => #{logger_results}complete.\n")
        end
        return result_arr
      end

      # Used primarily to map NIST 800-53 Revision 4 Security Controls
      # https://web.nvd.nist.gov/view/800-53/Rev4/impact?impactName=HIGH
      # to CSI Exploit & Static Code Anti-Pattern Matching Modules to
      # Determine the level of Testing Coverage w/ CSI.
      public
      def self.nist_800_53_requirements
        nist_800_53_requirements = {
          sp_module: self,
          section: 'ERROR HANDLING',
          nist_800_53_uri: 'http://web.nvd.nist.gov/view/800-53/Rev4/control?controlName=SI-11'
        }
        return nist_800_53_requirements
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
          logger_arr = #{self}.scan(
            :dir_path => 'optional path to dir defaults to .',
            :git_repo_root_uri => 'optional http uri of git repo scanned'
          )

          #{self}.authors
        }
      end
    end
  end
end
