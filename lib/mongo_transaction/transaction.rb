require 'mongo_mapper' #dependencies on mongo_mapper
class Transaction
  include MongoMapper::Document
  safe

  #key :before, Hash
  #key :after, Hash
  key :objects, Array #an array of objects participate in this transaction,
  #each is an array with :before, :after image
  key :state, String

  def add_object(object)
    @object_array ||= []
    @object_array << object
  end

  #before_save :translate_objects

  timestamps!

  def commit
    translate_objects
    #self.state = "initial"
    #self.save
    self.state = "pending"
    self.save

    @object_array.each do |object|
      if object.changed?
        object[:_pendingTransactions] ||= []
        object[:_pendingTransactions] << self.id unless object[:_pendingTransactions].include?(self.id) #todo, if we already are in self.id transaction, do not reapply the transaction
        object.save
      end
    end

    self.state = "committed"
    self.save

    @object_array.each do |object|
      #if object.changed?
        object[:_pendingTransactions] ||= []
        object[:_pendingTransactions].delete(self.id) # unless object[:_pendingTransactions].include?(self.id) #todo, if we already are in self.id transaction, do not reapply the transaction
        object.save
      #end
    end

    self.state = "done"
    self.save

    #db.accounts.update({name: t.source, pendingTransactions: {$ne: t._id}}, {$inc: {balance: -t.value}, $push: {pendingTransactions: t._id}})
    #db.accounts.update({name: t.destination, pendingTransactions: {$ne: t._id}}, {$inc: {balance: t.value}, $push: {pendingTransactions: t._id}})
    #db.accounts.find()
  end

  private
  def translate_objects
    @object_array.each do |object|
      if object.changed?
        before_image = {}
        after_image = {}
        object.attributes.each do |key, value|
          before_image[key] = object.send("#{key}_was")
          after_image[key] = value
        end
        self.objects << [object.class.to_s, before_image, after_image]
        #self.objects << {:before=>before_image,:after=>after_image}
      end
    end
  end
end