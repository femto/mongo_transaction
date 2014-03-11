# MongoTransaction

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'mongo_transaction'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo_transaction

## Usage

it's based on http://docs.mongodb.org/manual/tutorial/perform-two-phase-commits/
basiclly
```
@account1 = Account.create({name: "A", balance: 1000})
@account2 = Account.create({name: "B", balance: 1000})
```
```
@account1.transaction do
      @account1.deposit(100)
      @account2.withdraw(100)
      @account1.save
      @account2.save
end
```

or
```
Account.transaction do
      @account1.deposit(100)
      @account2.withdraw(100)
      @account1.save
      @account2.save
end
```
(see test/mongo_transaction_test.rb for an example).
## Contributing

1. Fork it ( http://github.com/<my-github-username>/mongo_transaction/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
