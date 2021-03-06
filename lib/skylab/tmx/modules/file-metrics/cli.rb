module Skylab::Tmx::Modules::FileMetrics
  class Cli < Skylab::Face::Cli
    namespace :"file-metrics" do
      SharedParameters = lambda do |op, req|

        req[:exclude_dirs] = ['.*']

        op.on('-D', '--exclude-dir DIR',
          'Folders whose basename match this pattern will not be',
          'descended into.  It can be specified multiple times',
          'with multiple patterns to narrow the search.',
          'If not provided, the default is to skip folders whose',
          "name starts with a '.' (period).  To include such",
          'dirs, specify "--exclude-dirs=[]" the first time you',
          'use this option in the command.  (it has the effect',
          'of clearing the "blacklist" of directories to skip)') do |dir|
            if '[]' == dir
              req[:exclude_dirs].clear
            else
              req[:exclude_dirs].push dir
            end
        end


        req[:include_names] = []

        op.on('-n', '--name NAME',
          "e.g. --name='*.rb'.  When present, this limits the",
          'files analyzed to the ones whose basename matches',
          'this pattern. It can be specified multiple times to',
          'add multiple filename patterns, which will broaden',
          'the search.  You should use single quotes to avoid',
          'shell expansion.',
          ' ',
          'When PATH is a file, this option is ignored.'
        ) do |pattern|
          req[:include_names].push pattern
        end

        op.on('-c', '--commands',
          'show the generated {find|wc} commands we (would) use') {
            req[:show_commands] = true }

        op.on('-l', '--list', 'list the resulting files that match the query (before running reports)') {
          req[:show_files_list] = true }

        req[:show_report] = true
        op.on('-R', '--no-report', "don't actually run the whole report") {
          req[:show_report] = false }
      end

      o :"line-count" do |op, req|
        syntax "#{invocation_string} [opts] [PATH [PATH [...]]]"
        op.banner = "
          Shows the linecount of each file, longest first. Show
          percentages of max for each file.   Will go recursively
          into directories.\n#{usage_string}
        ".gsub(/^ +/, '')

        SharedParameters.call(op, req)

        req[:count_comment_lines] = true
        req[:count_blank_lines]   = true
        op.on('-C', '--no-comments', "don't count lines with ruby-style comments") { req[:count_comment_lines] = false }
        op.on('-B', '--no-blank-lines', "don't count blank lines") { req[:count_blank_lines] = false }
      end

      def line_count opts, *paths
        require "#{File.dirname(__FILE__)}/api/line-count"
        Api::LineCount.run(paths, opts, self)
      end
    end
  end
end
