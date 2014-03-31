module ElchScan
  class Application
    module Dispatch
      def dispatch action = (@opts[:dispatch] || :help)
        case action
          when :help then @optparse.to_s.split("\n").each(&method(:log))
          when :version, :info then dispatch_info
          else
            if respond_to?("dispatch_#{action}")
              send("dispatch_#{action}")
            else
              abort("unknown action #{action}", 1)
            end
        end
      end

      def dispatch_info
        logger.log_without_timestr do
          log ""
          log "     Your version: #{your_version = Gem::Version.new(ElchScan::VERSION)}"

          # get current version
          logger.log_with_print do
            log "  Current version: "
            if cfg("application.check_version")
              require "net/http"
              log c("checking...", :blue)

              begin
                current_version = Gem::Version.new Net::HTTP.get_response(URI.parse(ElchScan::UPDATE_URL)).body.strip

                if current_version > your_version
                  status = c("#{current_version} (consider update)", :red)
                elsif current_version < your_version
                  status = c("#{current_version} (ahead, beta)", :green)
                else
                  status = c("#{current_version} (up2date)", :green)
                end
              rescue
                status = c("failed (#{$!.message})", :red)
              end

              logger.raw "#{"\b" * 11}#{" " * 11}#{"\b" * 11}", :print # reset cursor
              log status
            else
              log c("check disabled", :red)
            end
          end

          # more info
          log ""
          log "  ElchScan is brought to you by #{c "bmonkeys.net", :green}"
          log "  Contribute @ #{c "github.com/2called-chaos/elch_scan", :cyan}"
          log "  Eat bananas every day!"
          log ""
        end
      end

      def dispatch_edit_script
        record_filter(filter_script(@opts[:select_script]))
      end

      def dispatch_index
        if cfg(:movies).empty?
          log "You will need at least 1 one movie directory defined in your configuration."
          if RUBY_PLATFORM.include?("darwin")
            answer = ask("Do you want to open the file now? [Yes/no]")
            exec("open #{@config_src}") if ["", "y", "yes"].include?(answer.downcase)
          end
        else
          movies = _index_movies(cfg(:movies))
          old_count = movies.count
          log(
            "We have found " << c("#{movies.count}", :magenta) <<
            c(" movies in ") << c("#{cfg(:movies).count}", :magenta) << c(" directories")
          )

          if @opts[:console]
            log "You have access to the collection with " << c("movies", :magenta)
            log "Apply existent select script with " << c("apply_filter(movies, 'filter_name')", :magenta)
            log "Type " << c("exit", :magenta) << c(" to leave the console.")
            binding.pry(quiet: true)
          else
            # ask to filter
            if !@opts[:quiet] && @opts[:select_scripts].empty?
              answer = ask("Do you want to filter the results? [yes/No]")
              if ["y", "yes"].include?(answer.downcase)
                movies = apply_filter(movies, record_filter)
                old_count = movies.count
                collection_size_changed old_count, movies.count, "custom filter"
              end
            end

            # filter
            @opts[:select_scripts].each do |filter|
              movies = apply_filter(movies, filter_script(filter))
              collection_size_changed old_count, movies.count, "filter: #{filter}"
              old_count = movies.count
            end

            # permute
            permute_script(movies) if @opts[:permute]

            # ask to save
            if !@opts[:quiet] && !@opts[:output_file]
              answer = ask("Enter filename to save output or leave blank to print to STDOUT:")
              if !answer.empty?
                @opts[:output_file] = answer
              end
            end

            # format results
            formatter = "ElchScan::Formatter::#{@opts[:formatter]}".constantize.new(self)
            results = formatter.format(movies)

            # save
            if @opts[:output_file]
              File.open(@opts[:output_file], "w+") {|f| f.write(results) }
            else
              logger.log_without_timestr do
                results.each {|line| log line }
              end
            end
          end
        end
      end

      def collection_size_changed cold, cnew, reason = nil
        if cold != cnew
          log(
            "We have filtered " << c("#{cnew}", :magenta) <<
            c(" movies") << c(" (#{cnew - cold})", :red) <<
            c(" from originally ") << c("#{cold}", :magenta) <<
            (reason ? c(" (#{reason})", :blue) : "")
          )
        end
      end

      def _index_movies directories
        directories.each_with_object({}) do |dir, result|
          Find.find(dir) do |path|
            # calculate depth
            depth = path.scan(?/).count - dir.scan(?/).count
            depth -= 1 unless File.directory?(path)

            if depth == 1 && File.directory?(path)
              result[File.basename(path)] = Movie.new(
                self,
                dir: dir,
                path: path,
              )
            end
          end
        end
      end
    end
  end
end
