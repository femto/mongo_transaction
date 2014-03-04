module Mongo
  class Transaction
    module Plugins
      module Transaction
        extend ActiveSupport::Concern


        def destroy
          with_transaction_returning_status { super }
        end
        def save
          rollback_active_record_state! do
            with_transaction_returning_status { super }
          end
        end

        def save!
          with_transaction_returning_status { super }
        end

        def touch
          with_transaction_returning_status { super }
        end

        # Add the record to the current transaction so that the +after_rollback+ and +after_commit+ callbacks
        # can be called.
        def add_to_transaction(transaction)
          if transaction.add_object(self) #transaction.add_object(self)
            remember_transaction_record_state
          end
        end

        def with_transaction_returning_status
          status = nil
          self.class.transaction do |transaction|
            add_to_transaction(transaction)

            status = yield ##save done

            raise Mongo::Transaction::Rollback unless status
          end
          status
        end

        def transaction(*args, &block)
          self.class.transaction(*args, &block)
        end

        # Call the +after_commit+ callbacks.
        #
        # Ensure that it is not called if the object was never persisted (failed create),
        # but call it after the commit of a destroyed object.
        def committed! #:nodoc:
          run_callbacks :commit if destroyed? || persisted?
        ensure
          @_start_transaction_state.clear
        end

        # Call the +after_rollback+ callbacks. The +force_restore_state+ argument indicates if the record
        # state should be rolled back to the beginning or just to the last savepoint.
        def rolledback!(force_restore_state = false) #:nodoc:
          run_callbacks :rollback
        ensure
          restore_transaction_record_state(force_restore_state)
          clear_transaction_record_state
        end




        protected

        def rollback_active_record_state!
          remember_transaction_record_state
          yield
        rescue Exception
          restore_transaction_record_state
          raise
        ensure
          clear_transaction_record_state
        end


        # Save the new record state and id of a record so it can be restored later if a transaction fails.
        def remember_transaction_record_state #:nodoc:
          @_start_transaction_state ||= {}
          @_start_transaction_state[:id] = id #if has_attribute?(self.class.primary_key)
          unless @_start_transaction_state.include?(:_new)
            @_start_transaction_state[:_new] = @_new
          end
          unless @_start_transaction_state.include?(:_destroyed)
            @_start_transaction_state[:_destroyed] = @_destroyed
          end
          @_start_transaction_state[:level] = (@_start_transaction_state[:level] || 0) + 1
          @_start_transaction_state[:frozen?] = @attributes.frozen?
        end

        # Clear the new record state and id of a record.
        def clear_transaction_record_state #:nodoc:
          @_start_transaction_state[:level] = (@_start_transaction_state[:level] || 0) - 1
          @_start_transaction_state.clear if @_start_transaction_state[:level] < 1
        end

        # Restore the new record state and id of a record that was previously saved by a call to save_record_state.
        def restore_transaction_record_state(force = false) #:nodoc:
          unless @_start_transaction_state.empty?
            transaction_level = (@_start_transaction_state[:level] || 0) - 1
            if transaction_level < 1 || force
              restore_state = @_start_transaction_state
              was_frozen = restore_state[:frozen?]
              @attributes = @attributes.dup if @attributes.frozen?
              @_new = restore_state[:_new]
              @_destroyed  = restore_state[:_destroyed]
              if restore_state.has_key?(:id)
                self.id = restore_state[:id]
              else
                @attributes.delete(self.class.primary_key)
                @attributes_cache.delete(self.class.primary_key)
              end
              @attributes.freeze if was_frozen
            end
          end
        end

        # Determine if a record was created or destroyed in a transaction. State should be one of :new_record or :destroyed.
        def transaction_record_state(state) #:nodoc:
          @_start_transaction_state[state]
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