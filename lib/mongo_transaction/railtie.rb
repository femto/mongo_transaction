#require "mongo_mapper"
#require "rails"
#require "active_model/railtie"
#
## Need the action_dispatch railtie to have action_dispatch.rescu_responses initialized correctly
#require "action_dispatch/railtie"

module MongoMapper
  # = MongoMapper Railtie
  class Railtie < Rails::Railtie

    config.mongo_transaction = ActiveSupport::OrderedOptions.new

    #rake_tasks do
    #  load "mongo_transaction/railtie/database.rake"
    #end

    #initializer "mongo_transaction.set_configs", :after=>"mongo_mapper.set_configs" do |app|
    #  ActiveSupport.on_load(:mongo_transaction) do
    #    app.config.mongo_mapper.each do |k,v|
    #      send "#{k}=", v
    #    end
    #  end
    #end

    # This sets the database configuration and establishes the connection.
    #initializer "mongo_transaction.initialize_database" do |app|
    #  config_file = Rails.root.join('config/mongo.yml')
    #  if config_file.file?
    #    config = YAML.load(ERB.new(config_file.read).result)
    #    MongoMapper.setup(config, Rails.env, :logger => Rails.logger)
    #  end
    #end
    config.after_initialize do
      Mongo::Transaction.recover_partial_transaction
    end
  end
end
