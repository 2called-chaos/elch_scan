module ElchScan
  module Formatter
    class Base
      def initialize app
        @app = app
      end

      def logger
        @app.logger
      end

      def c *a
        @app.c(*a)
      end
    end
  end
end
