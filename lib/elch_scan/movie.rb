module ElchScan
  class Movie
    # dir => source movie directory (e.g. C:/Movies)
    # path => folder path of movie (e.g. C:/Movies/BestFilmEver)
    # dirname => source movie directory name (e.g. BestFilmEver)
    # nfo => path to nfo file
    attr_reader :attrs, :files

    def initialize app, attrs = {}
      @app = ->{app}
      @attrs = {}.merge(attrs).with_indifferent_access
      analyze!
    end

    def app
      @app.call
    end

    def method_missing(meth, *args, &blk)
      qmeth = meth.to_s.gsub("?", "") if meth.to_s.end_with?("?")
      smeth = meth.to_s.gsub("=", "") if meth.to_s.end_with?("=")

      if @attrs.keys.include?(meth.to_s)
        @attrs[meth]
      elsif @attrs.keys.include?(smeth)
        @attrs[smeth] = args.first
        @attrs[smeth]
      elsif @attrs.keys.include?(qmeth)
        !!@attrs[qmeth]
      else
        return false if qmeth
        super
      end
    end

    def set name, value
      @attrs[name] = value
      @attrs[name]
    end

    def analyze!
      set :dirname, File.basename(path)
      @files = Dir.glob("#{path.gsub("[", "\\[")}/*.*")
      matched = naming_select(@files)

      matched.each_with_object({}) {|(name, matches), r| set name, matches.try(:first) }
      set :movie, select_movies(@files).sort_by(&:length).first
      app.warn "No movie file found for #{dirname}" unless movie?
    end

    def naming_select strings
      raw_patterns = app.cfg(:application, :naming).symbolize_keys
      patterns = raw_patterns.map do |name, pattern|
        [name, /#{Regexp.escape(pattern).gsub("<baseFileName>", ".*?")}/]
      end

      patterns.each_with_object({}) do |(name, pattern), result|
        result[name] = strings.select{|s| s.match(pattern) }
      end
    end

    def select_movies strings
      strings.map{|s| File.basename(s) }.select do |s|
        app.cfg(:application, :video_extensions).split("\s").include?(s.split(".").last)
      end
    end

    def source
      FFMPEG::Movie.new("#{path}/#{movie}") rescue $!.message
    end

    def nfo!
      if nfo?
        XmlSimple.xml_in(nfo).tap do |nfo|
          if block_given?
            begin
              return yield(nfo)
            rescue
              return false
            end
          end
        end
      end
    rescue
      false
    end

    def name
      movie.split(".")[0..-2].join(".") if movie?
    end
  end
end
