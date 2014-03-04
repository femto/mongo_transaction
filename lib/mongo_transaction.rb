require "mongo_transaction/version"
require "mongo_transaction/models/transaction"
require "mongo_transaction/railtie" if defined?(Rails)
require "mongo_transaction/plugins/mongo_mapper" if defined?(MongoMapper)
#require "mongo_transaction/plugins/mongoid" if defined?(Mongoid)

module Mongo
  class Transaction
    class << self
      attr_accessor :scope
      def logger
        @logger ||= Rails.logger if defined?(Rails)
      end
      def recover_partial_transaction
        logger.info "recovering_partial_transaction at #{Time.now}" if logger
        Mongo::Transaction::Model::Transaction.where(:state=>"pending").each do |transaction|
          logger.info "resume from pending of transaction #{transaction.id} to done" if logger
          transaction.send(:resume_from_pending)
        end
        Mongo::Transaction::Model::Transaction.where(:state=>"committed").each do |transaction|
          logger.info "resume from committed of transaction #{transaction.id} to done" if logger
          transaction.send(:resume_from_committed)
        end
      end

      def scope
        @scope ||= Thread
      end

      def transaction_exist?
        !!scope.current[:__mongo_transaction__]
      end

      def current_transaction
        scope.current[:__mongo_transaction__] ||= Mongo::Transaction::Model::Transaction.new
      end

      def current_transaction=(current_transaction)
        scope.current[:__mongo_transaction__] = current_transaction
      end
    end
    #recover_partial_transaction #run at startup or at regular interval to ensure application is in consistent state
  end
end

#ActiveSupport.run_load_hooks(:mongo_transaction, Mongo::Transaction)
