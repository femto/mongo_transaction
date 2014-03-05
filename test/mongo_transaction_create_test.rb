require '../test/test_helper'
require 'test/unit'
require 'mongo_mapper'




class MongoTransactionTest < Test::Unit::TestCase
  def setup
    require 'model/account'
    #Account.delete_all
    #@account1 = Account.create({name: "A", balance: 1000})
    #@account2 = Account.create({name: "B", balance: 1000})
    #else
    #  MongoMapper.database = "GoChess"
    #end
  end
  def test_transaction_recovery

  end
  def test_recover_partial_transaction
    #a = 3
    #b = nil
    #computation = Autodeps.autorun do |computation|
    #  b = a
    #end
    #assert_equal b,a
    #
    #a = 5
    #computation.invalidate
    #assert_equal b,a

  end

  def test_account_transaction_commit
    @account1.transaction do
      @account1.deposit(100)
      @account2.withdraw(100)
      @account1.save
      @account2.save
    end
    #Transaction.create({source: "A", destination: "B", value: 100, state: "initial"})

  end

  def test_account_class_transaction_commit
    Account.transaction do
      @account1.deposit(100)
      @account2.withdraw(100)
      @account1.save
      @account2.save
    end
    #Transaction.create({source: "A", destination: "B", value: 100, state: "initial"})

  end

  def test_account_class_create_rollback
    Account.delete_all
    before_count = Account.count
    Account.transaction do
      Account.create({name: "A", balance: 1000})
      raise "rollback"
    end
    assert_equal before_count, Account.count
    #Transaction.create({source: "A", destination: "B", value: 100, state: "initial"})

  end

  def test_account_class_change_rollback
    Account.delete_all
    before_count = Account.count
    account = Account.create({name: "A", balance: 1000})
    Account.transaction do
      account.deposit(100)
      account.save
      raise "rollback"
    end
    account = Account.find_one({name: "A"})
    assert_equal 1000, account.balance

    #Account.transaction do
    #  account.deposit(100)
    #  account.save
    #  #raise "rollback"
    #end
    #account = Account.find_one({name: "A"})
    #assert_equal 1100, account.balance
    #Transaction.create({source: "A", destination: "B", value: 100, state: "initial"})

  end

  def test_transaction_rollback
    Account.transaction do |transaction|
      @account1.deposit(10000)
      @account2.withdraw(10000)
      @account1.save
      @account2.save
    end
    #Transaction.create({source: "A", destination: "B", value: 100, state: "initial"})

  end

end