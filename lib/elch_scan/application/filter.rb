module ElchScan
  module Filter
    def filter_script name
      "#{ROOT}/tmp/#{name}.esss"
    end

    def apply_filter collection, file
      app = @app
      eval File.read(file), binding, file
      collection
    end

    def permute_script collection, file = nil
      file ||= "#{Dir.tmpdir}/#{SecureRandom.urlsafe_base64}"
      FileUtils.mkdir(File.dirname(file)) if !File.exist?(File.dirname(file))
      if !File.exist?(file) || File.read(file).strip.empty?
        File.open(file, "w") {|f| f.puts("# Permute your collection, same as with the selector script filters.") }
      end
      system "#{cfg :application, :editor} #{file}"
      eval File.read(file), binding, file
      collection
    end

    def record_filter file = nil
      file ||= "#{Dir.tmpdir}/#{SecureRandom.urlsafe_base64}"
      FileUtils.mkdir(File.dirname(file)) if !File.exist?(File.dirname(file))
      if !File.exist?(file) || File.read(file).strip.empty?
        FileUtils.cp("#{ROOT}/doc/filter.rb", file)
      end
      system "#{cfg :application, :editor} #{file}"
      file
    end
  end
end
