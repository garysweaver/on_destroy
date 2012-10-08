module OnDestroy
  module Model
    extend ActiveSupport::Concern

    included do
      class_attribute :defined_is_deleted_if
      # use values from config
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
        self.do_not_delete = true if args.include?(:do_not_delete)
        self.set = options[:set] if options[:set]
        self.to = options[:to] if options[:to]
        if options[:is_deleted_if]
          # set defined_is_deleted_if to allow explicit set to nil
          self.defined_is_deleted_if = true
          self.is_deleted_if = options[:is_deleted_if]
        elsif (options[:to].is_a?(Proc))
          # if :to is a Proc, assume that a nil value means it is not deleted and if not-nil is deleted.
          # that is just a guess, based on the mark with deleted_at date example.
          self.is_deleted_if = Proc.new {|v| v != nil}
        else
          self.is_deleted_if = Proc.new {|v| v == send(options[:to])}
        end
      end
    end

    # Instance methods

    # if self.set then will use update_attributes! to set the self.set attribute to self.to or self.to.call if it is a Proc. 
    def do_on_destroy
      if self.set
        to_value = self.to.is_a?(Proc) ? self.to.call : self.to
        update_attributes! self.set => to_value
      end
      yield
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

    # if self.is_deleted_if is a Proc compares self.is_deleted_if.call to send(self.to).
    # if self.is_deleted_if is not nil compares self.is_deleted_if.call to send(self.to).
    # If self.is_deleted_if not a Proc, calls super.
    def destroyed?
      if self.is_deleted_if.is_a?(Proc)
        self.is_deleted_if.call(send(self.to))
      elsif self.is_deleted_if.nil? && !(self.defined_is_deleted_if == true)
        # will default to super only if self.is_deleted_if not defined by user
        super
      else
        self.is_deleted_if == send(self.to)
      end
    end

    alias_method :deleted?, :destroyed?
  end
end
