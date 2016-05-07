module DataAnon
  module Strategy
    module Field

      class Replicate
        def initialize(relationship_name, field_name = nil)
          @relationship_name = relationship_name
          @field_name = field_name
        end

        def rel_model(rel_instance, dest_db)
          return @rel_klass unless @rel_klass.nil?
          @rel_klass = rel_instance.class
          @rel_klass.establish_connection dest_db # :adapter => 'sqlite3', :database => 'db/development2.sqlite3'
          @rel_klass
        end

        def anonymize field
          @field_name ||= field.name
          ar_klass = field.table_name.classify.constantize
          ar_instance = ar_klass.new(field.ar_record.attributes)
          rel_instance = ar_instance.send(@relationship_name)
          # rel_klass = ar_klass.new.association(@relationship_name).klass
          if rel_instance
            rel_model(rel_instance, field.dest_db).find(rel_instance.id)[@field_name]
          else
            field.value
          end
        end
      end

    end
  end
end
