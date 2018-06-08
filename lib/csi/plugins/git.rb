# frozen_string_literal: true

require 'htmlentities'
require 'shellwords'

module CSI
  module Plugins
    # Used primarily in the past to clone local repos and generate an
    # html diff to be sent via email (deprecated).  In the future this
    # plugin may be used to expand upon capabilities required w/ Git.
    module Git
      @@logger = CSI::Plugins::CSILogger.create
      # Supported Method Parameters::
      # CSI::Plugins::Git.gen_html_diff(
      #   repo: 'required git repo name',
      #   branch: 'required git repo branch (e.g. master, develop, etc)',
      #   since: 'optional date, otherwise default to last pull'
      # )

      public

      def self.gen_html_diff(opts = {})
        git_repo_name = opts[:repo].to_s
        git_repo_branch = opts[:branch].to_s
        since_date = opts[:since]

        git_pull_output = '<div style="background-color:#CCCCCC; white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word;">'
        if since_date
          git_pull_output << "<h3>#{git_repo_name}->#{git_repo_branch} Diff Summary Since #{since_date}</h3>"
          git_entity = HTMLEntities.new.encode(`git log --since #{since_date} --stat-width=65535 --graph`.to_s.scrub)
        else
          git_pull_output << "<h3>#{git_repo_name}->#{git_repo_branch} Diff Summary Since Last Pull</h3>"
          git_entity = HTMLEntities.new.encode(`git log ORIG_HEAD.. --stat-width=65535 --graph`.to_s.scrub)
        end
        # For debugging purposes
        @@logger.info(git_entity)
        git_pull_output << git_entity.gsub("\n", '<br />')
        git_pull_output << '</div>'
        git_pull_output << '<br />'

        git_pull_output
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Git.get_author_by_line_range(
      #   repo_root: 'optional path to git repo root (defaults to ".")'
      #   from_line: 'required line number to start in range',
      #   to_line: 'required line number to stop in range',
      #   target_file: 'require file in which line range is queried'
      # )

      public

      def self.get_author_by_line_range(opts = {})
        repo_root = if opts[:repo_root].nil?
                      '.'
                    else
                      opts[:repo_root].to_s
                    end
        from_line = opts[:from_line].to_i
        to_line = opts[:to_line].to_i
        target_file = opts[:target_file].to_s
        target_file.gsub!(/^#{repo_root}\//, '')

        if File.directory?(repo_root) && File.file?(target_file)
          return `git --git-dir="#{Shellwords.escape(repo_root)}/.git" log -L #{from_line},#{to_line}:"#{Shellwords.escape(target_file)}" | grep Author | head -n 1`.to_s.scrub
        else
          return -1
        end
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::Git.dump_all_repo_branches(
      #   git_url: 'required git repo url'
      # )

      public

      def self.dump_all_repo_branches(opts = {})
        git_url = opts[:git_url].to_s.scrub
        all_repo_branches = `git ls-remote #{git_url}`.to_s.scrub

        all_repo_branches
      rescue => e
        raise e
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
        puts %{USAGE:
          git_html_resp = #{self}.gen_html_diff(
            repo: 'required git repo name',
            branch: 'required git repo branch (e.g. master, develop, etc)',
            since: 'optional date, otherwise default to last pull'
          )

          author = #{self}.get_author_by_line_range(
            repo_root: 'optional path to git repo root (defaults to ".")'
            from_line: 'required line number to start in range',
            to_line: 'required line number to stop in range',
            target_file: 'require file in which line range is queried'
          )

          all_repo_branches = #{self}.dump_all_repo_branches(
            git_url: 'required git repo url'
          )

          #{self}.authors
        }
      end
    end
  end
end
