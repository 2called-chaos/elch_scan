module ElchScan
  class Application
    def self.dispatch *a
      new(*a) do |app|
        app.load_config "~/.elch_scan"
      end
    end

    def initialize env, argv
      @env, @argv = env, argv
    end
  end
end
