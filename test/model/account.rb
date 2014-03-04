class Account
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
end