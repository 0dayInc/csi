# frozen_string_literal: false

require 'htmlentities'
require 'socket'

module CSI
  module SCAPM
    # SCAPM Module used to identify banned function
    # calls in C & C++ code per:
    # https://msdn.microsoft.com/en-us/library/bb288454.aspx
    module BannedFunctionCallsC
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::SCAPM::BannedFunctionCallsC.scan(
      #   :dir_path => 'optional path to dir defaults to .'
      #   :git_repo_root_uri => 'optional http uri of git repo scanned'
      # )

      public_class_method def self.scan(opts = {})
        dir_path = opts[:dir_path]
        git_repo_root_uri = opts[:git_repo_root_uri].to_s.scrub
        result_arr = []
        logger_results = ''
        rowno = 0

        CSI::Plugins::FileFu.recurse_dir(dir_path: dir_path) do |entry|
          if (File.file?(entry) && File.basename(entry) !~ /^csi.+(html|json|db)$/ && File.basename(entry) !~ /\.JS-BEAUTIFIED$/) && (File.extname(entry) == '.c' || File.extname(entry) == '.cpp' || File.extname(entry) == '.c++' || File.extname(entry) == '.cxx' || File.extname(entry) == '.h' || File.extname(entry) == '.hpp' || File.extname(entry) == '.h++' || File.extname(entry) == '.hh' || File.extname(entry) == '.hxx' || File.extname(entry) == '.ii' || File.extname(entry) == '.ixx' || File.extname(entry) == '.ipp' || File.extname(entry) == '.inl' || File.extname(entry) == '.txx' || File.extname(entry) == '.tpp' || File.extname(entry) == '.tpl')
            line_no_and_contents_arr = []
            filename_arr = []
            test_case_filter = "
              grep -Fn \
              -e 'strcpy' \
              -e 'strcpyA' \
              -e 'strcpyW' \
              -e 'wcscpy' \
              -e '_tcscpy' \
              -e '_mbscpy' \
              -e 'StrCpy' \
              -e 'StrCpyA' \
              -e 'StrCpyW' \
              -e 'lstrcpy' \
              -e 'lstrcpyA' \
              -e 'lstrcpyW' \
              -e '_tccpy' \
              -e '_mbccpy' \
              -e '_ftcscpy' \
              -e 'strncpy' \
              -e 'wcsncpy' \
              -e '_tcsncpy' \
              -e '_mbsncpy' \
              -e '_mbsnbcpy' \
              -e 'StrCpyN' \
              -e 'StrCpyNA' \
              -e 'StrCpyNW' \
              -e 'StrNCpy' \
              -e 'strcpynA' \
              -e 'StrNCpyA' \
              -e 'StrNCpyW' \
              -e 'lstrcpyn' \
              -e 'lstrcpynA' \
              -e 'lstrcpynW' \
              -e 'strcat' \
              -e 'strcatA' \
              -e 'strcatW' \
              -e 'wcscat' \
              -e '_tcscat' \
              -e '_mbscat' \
              -e 'StrCat' \
              -e 'StrCatA' \
              -e 'StrCatW' \
              -e 'lstrcat' \
              -e 'lstrcatA' \
              -e 'lstrcatW' \
              -e 'StrCatBuff' \
              -e 'StrCatBuffA' \
              -e 'StrCatBuffW' \
              -e 'StrCatChainW' \
              -e '_tccat' \
              -e '_mbccat' \
              -e '_ftcscat' \
              -e 'strncat' \
              -e 'wcsncat' \
              -e '_tcsncat' \
              -e '_mbsncat' \
              -e '_mbsnbcat' \
              -e 'StrCatN' \
              -e 'StrCatNA' \
              -e 'StrCatNW' \
              -e 'StrNCat' \
              -e 'StrNCatA' \
              -e 'StrNCatW' \
              -e 'lstrncat' \
              -e 'lstrcatnA' \
              -e 'lstrcatnW' \
              -e 'lstrcatn' \
              -e 'sprintfW' \
              -e 'sprintfA' \
              -e 'wsprintf' \
              -e 'wsprintfW' \
              -e 'wsprintfA' \
              -e 'sprintf' \
              -e 'swprintf' \
              -e '_stprintf' \
              -e 'wvsprintf' \
              -e 'wvsprintfA' \
              -e 'wvsprintfW' \
              -e 'vsprintf' \
              -e '_vstprintf' \
              -e 'vswprintf' \
              -e 'wvsprintf' \
              -e 'wvsprintfA' \
              -e 'wvsprintfW' \
              -e 'vsprintf' \
              -e '_vstprintf' \
              -e 'vswprintf' \
              -e 'strncpy' \
              -e 'wcsncpy' \
              -e '_tcsncpy' \
              -e '_mbsncpy' \
              -e '_mbsnbcpy' \
              -e 'StrCpyN' \
              -e 'StrCpyNA' \
              -e 'StrCpyNW' \
              -e 'StrNCpy' \
              -e 'strcpynA' \
              -e 'StrNCpyA' \
              -e 'StrNCpyW' \
              -e 'lstrcpyn' \
              -e 'lstrcpynA' \
              -e 'lstrcpynW' \
              -e '_fstrncpy' \
              -e 'strncat' \
              -e 'wcsncat' \
              -e '_tcsncat' \
              -e '_mbsncat' \
              -e '_mbsnbcat' \
              -e 'StrCatN' \
              -e 'StrCatNA' \
              -e 'StrCatNW' \
              -e 'StrNCat' \
              -e 'StrNCatA' \
              -e 'StrNCatW' \
              -e 'lstrncat' \
              -e 'lstrcatnA' \
              -e 'lstrcatnW' \
              -e 'lstrcatn' \
              -e '_fstrncat' \
              -e 'gets' \
              -e '_getts' \
              -e '_gettws' \
              -e 'IsBadWritePtr' \
              -e 'IsBadHugeWritePtr' \
              -e 'IsBadReadPtr' \
              -e 'IsBadHugeReadPtr' \
              -e 'IsBadCodePtr' \
              -e 'IsBadStringPtr' \
              -e 'memcpy' \
              -e 'RtlCopyMemory' \
              -e 'CopyMemory' \
              -e 'wmemcpy' #{entry}
            "

            str = HTMLEntities.new.encode(`#{test_case_filter}`.to_s.scrub)

            if !str.to_s.empty?
              # If str length is >= 64 KB do not include results. (Due to Mongo Document Size Restrictions)
              str = "1:Result larger than 64KB -> Size: #{str.to_s.length}.  Please click the \"Path\" link for more details." if str.to_s.length >= 64_000

              hash_line = {
                rowno: rowno += 1,
                timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S.%9N %z').to_s,
                test_case: nist_800_53_requirements,
                filename: filename_arr.push(git_repo_root_uri: git_repo_root_uri, entry: entry),
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
                if Dir.exist?("#{dir_path}/.git")
                  author = HTMLEntities.new.encode(CSI::Plugins::Git.get_author_by_line_range(
                                                     repo_root: dir_path,
                                                     from_line: line_no,
                                                     to_line: line_no,
                                                     target_file: entry
                                                   ))
                else
                  author = 'N/A'
                end
                hash_line[:line_no_and_contents] = line_no_and_contents_arr.push(line_no: line_no,
                                                                                 contents: contents,
                                                                                 author: author)

                current_count += 2
              end
              result_arr.push(hash_line)
              logger_results = "#{logger_results}x" # Catching bugs is good :)
            else
              logger_results = "#{logger_results}~" # Seeing progress is good :)
            end
          end
        end
        logger_banner = "http://#{Socket.gethostname}:8808/doc_root/csi-#{CSI::VERSION.to_s.scrub}/#{to_s.scrub.gsub('::', '/')}.html"
        if logger_results.empty?
          @@logger.info("#{logger_banner}: No files applicable to this test case.\n")
        else
          @@logger.info("#{logger_banner} => #{logger_results}complete.\n")
        end
        result_arr
      end

      # Used primarily to map NIST 800-53 Revision 4 Security Controls
      # https://web.nvd.nist.gov/view/800-53/Rev4/impact?impactName=HIGH
      # to CSI Exploit & Static Code Anti-Pattern Matching Modules to
      # Determine the level of Testing Coverage w/ CSI.

      public_class_method def self.nist_800_53_requirements
        nist_800_53_requirements = {
          sp_module: self,
          section: 'INFORMATION INPUT VALIDATION',
          nist_800_53_uri: 'http://web.nvd.nist.gov/view/800-53/Rev4/control?controlName=SI-10'
        }
        nist_800_53_requirements
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
          banned_function_calls_c_arr = #{self}.scan(
            :dir_path => 'optional path to dir defaults to .',
            :git_repo_root_uri => 'optional http uri of git repo scanned'
          )

          #{self}.authors
        "
      end
    end
  end
end
