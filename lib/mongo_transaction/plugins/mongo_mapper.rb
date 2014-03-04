module Mongo
  class Transaction
    module Plugins
      module Transaction
        extend ActiveSupport::Concern

        #def save
        #
        #end
        def transaction(*args, &block)
          self.class.transaction(*args, &block)
        end
        module ClassMethods
          def transaction(options={})
            me_transaction = !Mongo::Transaction.transaction_exist?
            #if options[:required_new]
            #  transaction = Mongo::Transaction.current_transaction
            #  new_transaction = true
            #else
              transaction = Mongo::Transaction.current_transaction
            #end

            begin
              yield transaction
            rescue Exception#rollback
              transaction.rollback if me_transaction
            else #commit
              transaction.commit if me_transaction
            ensure
            end
          end
        end

      end
    end
  end
end
module MongoMapper
  module Document
    include Mongo::Transaction::Plugins::Transaction
  end
end