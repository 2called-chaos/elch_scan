module ElchScan
  # Logger Singleton
  MAIN_THREAD = ::Thread.main
  def MAIN_THREAD.app_logger
    MAIN_THREAD[:app_logger] ||= Banana::Logger.new
  end

  class Application
    include Dispatch
    include Filter

    # =========
    # = Setup =
    # =========
    def self.dispatch *a
      new(*a) do |app|
        app.load_config "~/.elch_scan.yml"
        app.apply_config
        app.parse_params
        app.dispatch
      end
    end

    def initialize env, argv
      @env, @argv = env, argv
      @opts = {
        dispatch: :index,
        quiet: false,
        output_file: nil,
        formatter: "Plain",
        select_scripts: [],
      }
      yield(self)
    end

    def parse_params
      @optparse = OptionParser.new do |opts|
        opts.banner = "Usage: elch_scan [options]"

        opts.on("--generate-config", "Generate sample configuration file in ~/.elch_scan.yml") { @opts[:dispatch] = :generate_config }
        opts.on("-h", "--help", "Shows this help") { @opts[:dispatch] = :help }
        opts.on("-v", "--version", "Shows version and other info") { @opts[:dispatch] = :info }
        opts.on("-f", "--formatter HTML", "Use formatter") {|f| @opts[:formatter] = f }
        opts.on("-o", "--output FILENAME", "Write formatted results to file") {|f| @opts[:output_file] = f }
        opts.on("-e", "--edit SELECT_SCRIPT", "Edit selector script") {|s| @opts[:dispatch] = :edit_script; @opts[:select_script] = s }
        opts.on("-s", "--select [WITH_SUBS,NO_NFO]", Array, "Filter movies with saved selector scripts") {|s| @opts[:select_scripts] = s }
        opts.on("-p", "--permute", "Open editor to write permutation code for collection") {|s| @opts[:permute] = true }
        opts.on("-q", "--quiet", "Don't ask to filter or save results") { @opts[:quiet] = true }
        opts.on("-c", "--console", "Start console to play around with the collection") {|f| @opts[:console] = true }
      end

      begin
        @optparse.parse!(@argv)
      rescue OptionParser::ParseError => e
        abort(e.message)
        dispatch(:help)
        exit 1
      end
    end

    def load_config file
      @config_src = File.expand_path(file)
      @config = YAML.load_file(@config_src)
      raise "empty config" if !@config || @config.empty? || !@config.is_a?(Hash)
      @config = @config.with_indifferent_access
    rescue Exception => e
      if e.message =~ /no such file or directory/i
        if @argv.include?("--generate-config")
          @config = { application: { logger: { colorize: true } } }.with_indifferent_access
        else
          log "Please create or generate a configuration file."
          log(
            c("Use ") << c("elch_scan --generate-config", :magenta) <<
            c(" or create ") << c("~/.elch_scan.yml", :magenta) << c(" manually.")
          )
          abort "No configuration file found.", 1
        end
      elsif e.message =~ //i
        abort "Configuration file is invalid.", 1
      else
        raise
      end
    end

    def apply_config
      logger.colorize = cfg(:application, :logger, :colorize)
      (cfg(:formatters) || []).each do |f|
        begin
          require File.expand_path(f)
        rescue LoadError
          abort "The custom formatter file wasn't found: " << c("#{f}", :magenta)
        end
      end
    end

    def cfg *keys
      keys = keys.flatten.join(".").split(".")
      keys.inject(@config) {|cfg, skey| cfg.try(:[], skey) }
    end

    # ==========
    # = Logger =
    # ==========
    [:log, :warn, :abort, :debug].each do |meth|
      define_method meth, ->(*a, &b) { Thread.main.app_logger.send(meth, *a, &b) }
    end

    def logger
      Thread.main.app_logger
    end

    # Shortcut for logger.colorize
    def c str, color = :yellow
      logger.colorize? ? logger.colorize(str, color) : str
    end

    def ask question
      logger.log_with_print(false) do
        log c("#{question} ", :blue)
        STDOUT.flush
        gets.chomp
      end
    end
  end
end
