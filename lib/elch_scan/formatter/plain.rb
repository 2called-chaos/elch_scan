module ElchScan
  module Formatter
    class Plain < Base
      def format results
        return ["no results"] if results.empty?
        # name, resolution, languages
        table = [[], [], [], []]

        results.each do |name, movie|
          table[0] << name
          table[1] << (movie.source.resolution rescue "?")
          table[2] << (movie.nfo! do |n|
            n["fileinfo"][0]["streamdetails"][0]["audio"].map do |s|
              s.try(:[], "language").try(:[], 0)
            end.reject(&:nil?)
          end.presence || ["–"]).join(", ")

          size = movie.source.size rescue nil
          table[3] << (size ? ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(size, {}) : "?")
        end

        [nil] + render_table(table, ["Name", "Resolution", "Audio languages", "Movie size"])
      end

      def colorize_name str
        m = str.match(/(.*?)(?:\s*)(\(.*?\))(?:\s*)(\[[0-9]+\])?(\s*)?/)
        return str if !m
        c("#{m[1]}").tap do |r|
          r << m[4] if m[4]
          r << c(" #{m[2]}", :blue) if m[2]
          r << c(" #{m[3]}", :magenta) if m[3]
        end
      end

      def render_table table, headers = []
        [].tap do |r|
          col_sizes = table.map{|col| col.map(&:to_s).map(&:length).max }
          headers.map(&:length).each_with_index do |length, header|
            col_sizes[header] = [col_sizes[header], length].max
          end

          # header
          if headers.any?
            r << [].tap do |line|
              col_sizes.count.times do |col|
                line << "#{c headers[col].ljust(col_sizes[col])}"
              end
            end.join(c " | ", :red)
            r << c("".ljust(col_sizes.sum + ((col_sizes.count - 1) * 3), "-"), :red)
          end

          # prettify movie sizes
          table[3].map! do |size|
            size = size.ljust(col_sizes[3])
            m = size.match(/(.*?) ([^\s]*)(\s*)/)
            color = case(m[2])
              when "B", "KB" then :magenta
              when "MB" then :green
              else :red
            end
            c("#{m[3]}#{m[1]} #{m[2]}", color)
          end

          # records
          table[0].count.times do |row|
            r << [].tap do |line|
              col_sizes.count.times do |col|
                line << "#{c colorize_name("#{table[col][row]}".encode!('UTF-8','UTF8-MAC').ljust(col_sizes[col]))}"
              end
            end.join(c " | ", :red)
          end
        end
      end
    end
  end
end
