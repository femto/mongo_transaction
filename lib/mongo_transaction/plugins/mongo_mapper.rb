module Mongo
  class Transaction
    module Plugins
      module Transaction
        extend ActiveSupport::Concern

        #def save
        #
        #end

        def transaction
          transaction = Mongo::Transaction.current_transaction
          begin
            yield transaction
          rescue Exception#rollback
            transaction.rollback
          else #commit
            transaction.commit
          ensure
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