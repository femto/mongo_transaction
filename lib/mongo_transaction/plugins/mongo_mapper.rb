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
              if me_transaction
                transaction.rollback
              else
                raise #re raise the exception
              end
            else #commit
              transaction.commit if me_transaction
            ensure
              Mongo::Transaction.current_transaction = nil if me_transaction
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