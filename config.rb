module App
  class Conf
    @default = {}
    @dev = {}
    @prod = {}

    def self.default(opts=nil)
      opts.nil? ? @default : @default.deep_merge!(opts)
    end

    def self.dev(opts=nil)
      opts.nil? ? @dev : @dev.deep_merge!(opts)
    end

    def self.prod(opts=nil)
      opts.nil? ? @prod : @prod.deep_merge!(opts)
    end
  end
end

class Neo::ConfigFiles
  @config_files =
    %W(#{Neo.app_dir}/config/*.rb #{Neo.app_dir}/modules/*/config/*.rb).reduce([]) {|memo, dir|
      Dir[dir].each do |file|
        memo << file
      end
      memo
    }
  def self.get
    @config_files
  end
  def self.remove(file)
    @config_files.delete_if {|conf_file| file == conf_file}
  end
end


module Neo
  module Config
    attr_accessor :main

    def initialize
      config_files = Neo::ConfigFiles.get
      config_files.each do |file|
          require file
          Neo::ConfigFiles.remove file
      end

      env_var = App::Conf.default[:env]
      env = App::Conf.send(env_var)
      Neo::Params.env = env_var
      @main = App::Conf.default
      @main.deep_merge!(env)
    end

    def [](key)
      @main[key]
    end

    def []=(key,value)
      @main[key] = value
    end

    make_modular
  end
end