module DataAnon
  module Strategy
    module PersistThruUpdate

      private

      def persist!(record)
        ar_model = record.class
        ar_record = ar_model.find_or_initialize_by(id: record.id)
        ar_record.update_attributes!(record.attributes)
      end

    end
  end
end
