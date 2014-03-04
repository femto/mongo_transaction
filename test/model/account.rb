class Account
  class InsufficentFundException < StandardError;end
  include MongoMapper::Document
  safe


  key :name, String
  key :balance, Integer, :default=>0

  timestamps!

  ensure_index(:name, :unique => true)
  #ensure_index(:match_count)
  #ensure_index(:win_count)
  #ensure_index(:step_count)
  #ensure_index(:guess_hits_count)

  protected :balance=

  def withdraw(amount)
    if self.balance < amount
      raise InsufficentFundException
    end
    self.balance -= amount
  end
  def deposit(amount)
    self.balance += amount
  end
end