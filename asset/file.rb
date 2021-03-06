require 'fileutils'
require 'pathname'


class Neo::Asset::File
  # dosya kendi yolunu ve kopya yolunu ayarlar
  #   eğer dosyanın kopyası yoksa veya orjinalde değiştirilmişse yenisini kopyalar
  # @path: dosya yolu
  # @type: dosya tipi (css, js)
  # @virt_path: dosyanın kopyalanacağı yol
  # @modified: dosya güncellenmiş mi?
  #
  def initialize(path)
    @path = path
    @org_path = Neo::Asset::Manager.module_dir + path
    @type = File.extname(@org_path)[1..-1]
    @virt_path = Neo::Asset::Manager.media_dir + path
  end

  def parse
    parsers = Neo::Asset::Manager.parsers[Neo::Params.env.to_sym][@type.to_sym]
    if parsers.nil?
      @path
    else
      initial_path = @org_path
      parsers.reduce(@path) do |path, parser|

        is_css_parsed = ((parser == 'sass' or parser == 'scss') and File.file?(@virt_path.gsub(File.extname(@virt_path),'.css')))
        is_js_parsed = (parser == 'coffee' and File.file?(@virt_path.gsub(File.extname(@virt_path),'.js')))

        if (is_css_parsed or is_js_parsed) and not Neo::Asset::Manager.changed_files.include? @path
          if parser == 'sass' or parser == 'scss'
            path.gsub(File.extname(@virt_path),'.css')
          else
            path.gsub(File.extname(@virt_path),'.js')
          end
        else
          content = Neo::Asset::Parsers.const_get(parser.camelize, false).parse(initial_path)
          if content
            if content[:extension].nil?
              File.write(@virt_path, content[:content])
              path
            else
              FileUtils.cp(initial_path, @virt_path)
              initial_path = @virt_path.gsub(File.extname(@virt_path),content[:extension])
              File.write(initial_path, content[:content])
              path.gsub(File.extname(@virt_path),content[:extension])
            end
          else
            FileUtils.cp(initial_path, @virt_path)
            path
          end
        end
      end
    end
  end

  def mark_for_copy
    if is_changed?
      Neo::Asset::Manager.changed_files << @path
    end
  end


  def copy
    if is_changed?
      directory = File.dirname(@virt_path)
      FileUtils.mkdir_p(directory) unless File.directory?(directory)
      FileUtils.cp(@org_path, @virt_path)
    end
  end

  # gets the imported files for scss and sass
  def get_imports
    imports = []
    File.open(@org_path,encoding:'UTF-8').each_line do |line|
      matches = line.scan /@import( +("|')?|("|'))([^'" ]+)(("|')? *|("|')).*/
      if matches[0] and matches[0][3]
        imports << matches[0][3].strip
      end
    end
    imports
  end

  # in scss and sass files it checks the change of imported files
  def imported_changed?
    if %w( .scss .sass ).include? File.extname(@org_path)
      get_imports.reduce(false) do |memo, import|
        imported_file = "#{File.dirname @path}/_#{import}#{File.extname(@org_path)}"
        if File.file? "#{Neo::Asset::Manager.module_dir}/#{imported_file}"
          file = Neo::Asset::File.new(imported_file)
          file.is_changed? ? true : memo
        else
          memo
        end
      end
    else
      false
    end
  end

  def is_changed?
    not File.file?(@virt_path) or imported_changed? or File.mtime(@org_path) > File.mtime(@virt_path)
  end

  def fill_content
    @content = File.read @org_path
  end
end