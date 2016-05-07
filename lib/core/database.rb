module DataAnon
  module Core

    class Database
      include Utils::Logging

      def initialize name
        @name = name
        @strategy = DataAnon::Strategy::Whitelist
        @user_defaults = {}
        @tables = []
        @execution_strategy = DataAnon::Core::Sequential
        ENV['parallel_execution'] = 'false'
        I18n.enforce_available_locales = false
      end

      def strategy strategy
        @strategy = strategy
      end

      def execution_strategy execution_strategy
        @execution_strategy = execution_strategy
        ENV['parallel_execution'] = 'true' if execution_strategy == DataAnon::Parallel::Table
      end

      def source_db connection_spec
        @source_database = connection_spec
      end

      def destination_db connection_spec
        @destination_database = connection_spec
      end

      def source_and_destination_db connection_spec
        @source_database = @destination_database = connection_spec
      end

      def default_field_strategies default_strategies
        @user_defaults = default_strategies
      end

      def table (name, &block)
        @source_database or raise 'source database cannot be nil'
        @destination_database or raise 'source database cannot be nil'
        table = @strategy.new(@source_database, @destination_database, name, @user_defaults).process_fields(&block)
        @tables << table
      end
      alias :collection :table

      def anonymize
        begin
          @execution_strategy.new.anonymize @tables
        rescue => e
          logger.error "\n#{e.message} \n #{e.backtrace}"
        end
        if @strategy.whitelist?
          logger.info("Fields missing the anonymization strategy")
          @tables.each { |table| table.fields_missing_strategy.print }
        end

        @tables.each { |table| table.errors.print }
      end

    end

    class Sequential
      def anonymize tables
        tables.each do |table|
          begin
            table.process
          rescue => e
            logger.error "\n#{e.message} \n #{e.backtrace}"
          end
        end
      end
    end

  end
end