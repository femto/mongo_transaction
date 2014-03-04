$: << File.join(File.expand_path(File.dirname(__FILE__)),"..","lib")
$: << File.join(File.expand_path(File.dirname(__FILE__)),"..","test")

require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :logger => Logger.new(STDOUT))
#if Rails.env.test?
MongoMapper.database = "mongo_transaction_test"
require 'mongo_transaction'


