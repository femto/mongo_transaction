require "mongo_transaction/version"
require "mongo_transaction/transaction"

module Mongo
  class Transaction
    class << self
      def recover_partial_transaction
        ::Transaction.where(:state=>"pending").each do |transaction|
          transaction.send(:resume_from_pending)
        end
        ::Transaction.where(:state=>"committed").each do |transaction|
          transaction.send(:resume_from_committed)
        end
      end
    end
    recover_partial_transaction #run at startup or at regular interval to ensure application is in consistent state
  end
end
