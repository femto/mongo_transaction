require 'mongo_mapper' #dependencies on mongo_mapper
module Mongo
  class Transaction
    module Model
      class Transaction
        include MongoMapper::Document
        set_collection_name "transaction"
        safe

        #key :before, Hash
        #key :after, Hash
        key :objects, Array #an array of objects participate in this transaction,
        #each is an array with :before, :after image
        key :state, String

        #ensure_index(:state)

        def add_object(object)
          @object_array ||= []
          @object_array << object if !@object_array.include?(object)
        end

        #before_save :translate_objects

        timestamps!

        def add_objects_to_transaction
          self.objects.each do |object_class, type, id, before_image, after_image|
            if type == "changed"
              object = Object.const_get(object_class).find(id) #changed
              object[:_pendingTransactions] ||= []
              if !object[:_pendingTransactions].include?(self.id)
                object.attributes = after_image

                object[:_pendingTransactions] << self.id unless object[:_pendingTransactions].include?(self.id) #todo, if we already are in self.id transaction, do not reapply the transaction
                object.save
              end
            else #added, destroyed case
            end
          end
        end


        def commit
          translate_objects

          #self.state = "initial"
          #self.save

          self.state = "pending"
          self.save

          resume_from_pending

        end

        def rollback
          #only
          #puts "rollback"
          #if ["pending"].include?(self.state) || self.state.nil?
          #  translate_objects
          #
          #  self.state = "canceling"
          #  self.save
          #else
          #  #["committed", "done"].include?(self.state)
          #  raise "can't rollback an already committed or done transaction " + self.id.to_s
          #end


        end

        protected
        def resume_from_pending
          add_objects_to_transaction

          self.state = "committed"
          self.save

        end

        def resume_from_committed
          self.objects.each do |object_class, type, id, before_image, after_image|
            #if object.changed?
            if type == "changed"
              object = Object.const_get(object_class).find(id) #changed
              object[:_pendingTransactions] ||= []
              object[:_pendingTransactions].delete(self.id) # unless object[:_pendingTransactions].include?(self.id) #todo, if we already are in self.id transaction, do not reapply the transaction
              object.save
            else
            end
          end

          self.state = "done"
          self.save
        end

        private
        def translate_objects
          @object_array.each do |object|
            if object.changed?
              before_image = {}
              after_image = {}
              object.attributes.each do |key, value|
                before_image[key] = object.send("#{key}_was")
                after_image[key] = value
              end
              self.objects << [object.class.to_s, "changed", object.id, before_image, after_image]
              #self.objects << {:before=>before_image,:after=>after_image}
            end
          end
        end
      end
    end
  end
end