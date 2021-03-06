require 'sass'

module Neo
  module Asset
    module Parsers
      module Sass
        attr_accessor :extension, :options

        def initialize
          @extension = 'sass'
          set_options
        end

        def set_options
          # init sass parser with these options
          @options = {
            style: :nested,
            :load_paths => get_load_paths,
            :cache => true,
            :cache_location => './.sass-cache',
            :syntax => @extension.to_sym,
            :filesystem_importer => ::Sass::Importers::Filesystem
          }
        end

        # adds compass to load paths
        #   can be added more load paths later
        # @return [Array<String>] sass load paths
        def get_load_paths
          paths = ['.']
          compass = Neo.detect_gem_path 'compass-core'
          compass ? paths + ["#{compass}/stylesheets"] : paths
        end

        # Takes a file and parse it with Sass parser
        # @param file [String] path of the file which will be parsed
        # @return [{Symbol=>String}, false] which includes
        #   * :content   => the parsed content
        #   * :extension => converting type of the file
        #   or false if file name starts with '_' because these type of files
        #   must be imported and parsed with its parent file in sass.
        def parse(file)
          if ::File.basename(file, ".#{@extension}").start_with?('_')
            false
          else
            engine = ::Sass::Engine.for_file(file, @options)
            {content: engine.render, extension: '.css'}
          end
        end

        make_modular
      end
    end
  end
end