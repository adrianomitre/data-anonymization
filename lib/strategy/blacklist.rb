module DataAnon
  module Strategy
    class Blacklist < DataAnon::Strategy::Base

      def ensure_all_field_names_match source_record
        field_names = @fields.map { |field, _strategy| field }
        fields_do_not_match = field_names - source_record.attribute_names
        unless fields_do_not_match.empty?
          raise ArgumentError, "#{'field'.pluralize(fields_do_not_match.count)} '#{fields_do_not_match.join("', '")}' not found on table '#{source_record.class.table_name}'"
        end
      end

      def process_record index, source_record
        ensure_all_field_names_match source_record
        dest_record = dest_table.new source_record.attributes, without_protection: true
        @fields.each do |field_name, strategy|
          field_value = dest_record.attributes[field_name]
          unless field_value.nil? || is_primary_key?(field_name)
            field = DataAnon::Core::Field.new(field_name, field_value, index, dest_record, @name, @destination_database)
            dest_record[field_name] = strategy.anonymize(field)
          end
        end
        persist!(dest_record)
      end

    end
  end
end
