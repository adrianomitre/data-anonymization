module DataAnon
  module Core

    class Field

      def initialize name, value, row_number, ar_record, table_name = "unknown", dest_db = nil
        @name = name
        @value = value
        @row_number = row_number
        @ar_record = ar_record
        @table_name = table_name
        @dest_db = dest_db
      end

      attr_accessor :name, :value, :row_number, :ar_record, :table_name, :dest_db

      alias :collection_name :table_name

    end

  end
end