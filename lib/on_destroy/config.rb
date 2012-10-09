module OnDestroy
  OPTIONS = [
    :do_not_delete,
    :on_destroy_options,
  ]
  
  class << self
    OPTIONS.each{|o|attr_accessor o; define_method("#{o}?".to_sym){!!send("#{o}")}}
    def configure(&blk); class_eval(&blk); end
  end
end

# defaults
#OnDestroy.configure do
#  self.do_not_delete = false
#  self.on_destroy_options = nil
#end
