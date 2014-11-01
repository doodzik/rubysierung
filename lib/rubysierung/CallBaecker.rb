require "CallBaecker/version"

module CallBaecker
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def method_added(name)
      return if @__last_methods_added && @__last_methods_added.include?(name)
      
      # setup
      # TODO make it pluggable
      # it shouldnt be limited to rubisierung
      has_before_hook = instance_variables.include? :@__setup_instance_method
      if has_before_hook
        params = @__setup_instance_method.call(self, name)
      end
      
      with = :"#{name}_with_before_each_method"
      without = :"#{name}_without_before_each_method"
      @__last_methods_added = [name, with, without]
      _self = self
      define_method with do |*args, &block|
        callee = caller.first
        @__last_args = *args
        catch :CallBaeckerDone do
          # before hook
          # TODO make it pluggable
          # it shouldnt be limited to rubisierung
          if has_before_hook
            *args = _self.instance_variable_get(:@__before_hook).call(params, args[0], callee)
          end
          send without, *args, &block
        end
      end
      # teardow
      alias_method without, name
      alias_method name, with
      @__last_methods_added = nil
    end


    def singleton_method_added(name)
      return if @__last_methods_added && @__last_methods_added.include?(name)

      # setup
      # TODO make it pluggable
      # it shouldnt be limited to rubisierung
      has_before_hook = instance_variables.include? :@__setup_class_method
      if has_before_hook
        params = @__setup_class_method.call(self, name)
      end
      
      with = :"#{name}_with_before_each_method"
      without = :"#{name}_without_before_each_method"
      @__last_methods_added = [name, with, without]
      define_singleton_method with do |*args, &block|
        @__last_args = *args
        callee = caller.first
        catch :CallBaeckerDone do
          # before hook
          # TODO make it pluggable
          # it shouldnt be limited to rubisierung
          if has_before_hook  
            *args = @__before_hook.call(params, args[0], callee)
          end
          send without, *args, &block
        end
      end
      # TODO teardown
      singleton_class.send(:alias_method, without, name.to_sym)
      singleton_class.send(:alias_method, name.to_sym, with)
      @__last_methods_added = nil
    end
  end
end

