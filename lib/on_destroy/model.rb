module OnDestroy
  module Model
    extend ActiveSupport::Concern

    included do
      OnDestroy::OPTIONS.each do |key|
        class_attribute key, instance_writer: true
        self.send("#{key}=".to_sym, OnDestroy.send(key))
      end
      around_destroy :do_on_destroy
    end

    module ClassMethods
      # a shortcut to set configuration:
      # self.do_not_delete, self.set, self.to, self.is_deleted_if
      # and to default self.is_deleted_if to a proc that 
      def on_destroy(*args)
        options = args.extract_options!
        self.do_not_delete = args.include?(:do_not_delete)
        self.on_destroy_options = options
      end
    end

    # Instance methods

    # if self.set then will use update_attributes! to set the self.set attribute to self.to or self.to.call if it is a Proc. 
    def do_on_destroy
      if self.on_destroy_options
        o_set = self.on_destroy_options[:set]
        o_to = self.on_destroy_options[:to]
        update_attributes! o_set => (o_to.is_a?(Proc) ? o_to.call : o_to) unless o_set.nil?
        yield
      end
    end

    # if self.do_not_delete? runs no/empty callback on :destroy, otherwise calls super.
    def destroy
      if self.do_not_delete?
        # don't destroy
        run_callbacks(:destroy) {}
      else
        # destroy
        super
      end
    end

    # runs delete callback on :destroy
    def really_destroy
      run_callbacks(:destroy) {delete}
    end

    def destroyed?
      if self.on_destroy_options
        is_deleted_if = self.on_destroy_options[:is_deleted_if]
        o_set = self.on_destroy_options[:set]
        o_to = self.on_destroy_options[:to]
        if is_deleted_if.is_a?(Proc)
          send(o_set) == is_deleted_if.call
        elsif !(o_set.nil?)
          if o_to.is_a?(Proc)
            # assume that a :to defined as a Proc is going to evaluate to a non-nil to indicate the model is null
            send(o_set) != nil
          else
            send(o_set) == o_to
          end
        end
      else
        super
      end
    end

    alias_method :deleted?, :destroyed?
  end
end
