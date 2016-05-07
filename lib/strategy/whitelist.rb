module DataAnon
  module Strategy
    class Whitelist < DataAnon::Strategy::Base

      def self.whitelist?
        true
      end

      def process_record(index, source_record)
        dest_record_map = {}
        dest_record = dest_table.new source_record.attributes, without_protection: true
        dest_record.attributes.each do |field_name, field_value|
          unless field_value.nil? || is_primary_key?(field_name)
            field = DataAnon::Core::Field.new(field_name, field_value, index, dest_record, @name, @destination_database)
            field_strategy = @fields[field_name] || default_strategy(field_name)
            dest_record_map[field_name] = field_strategy.anonymize(field)
          end
        end
        dest_record.save!
      end


    end
  end
end
