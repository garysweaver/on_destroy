module OnDestroy
  OPTIONS = [
    :do_not_delete,
    :set,
    :to,
    :is_deleted_if
  ]
  
  class << self
    OPTIONS.each{|o|attr_accessor o; define_method("#{o}?".to_sym){!!send("#{o}")}}
    def configure(&blk); class_eval(&blk); end
  end
end

# Do it for everything
#OnDestroy.configure do
#  self.do_not_delete = true
#  self.set = [:deleted]
#  self.to = true
#end
