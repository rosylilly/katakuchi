require 'active_support/concern'

module Katakuchi::Role
  extend ActiveSupport::Concern

  module ClassMethods
    def actor(model)
      @base_model = model
    end

    def extend_class(&block)
      extend_class_blocks.push(block)
    end

    def inject(instance_or_relation)
      return nil if instance_or_relation.nil?

      case instance_or_relation
      when Array then inject_with_array(instance_or_relation)
      when ActiveRecord::Relation then inject_with_relation(instance_or_relation)
      when Katakuchi::Relation then instance_or_relation
      else inject_with_instance(instance_or_relation)
      end
    end

    def inject_with_array(array)
      array.each do |obj|
        inject_with_instance(obj)
      end

      return array
    end

    def inject_with_relation(relation)
      relation = Katakuchi::Relation.new(relation, self)

      return relation
    end

    def inject_with_instance(obj)
      if !obj.is_a?(self) && obj.kind_of?(@base_model)
        obj.extend(self)

        extend_class_blocks.each |extend_class_block|
          obj.singleton_class.class_eval(extend_class_block)
        end
      end

      return obj
    end

    private

    def role_name
      @role_name ||= self.name.to_s.underscore
    end

    def extend_class_blocks
      @extend_class_blocks ||= []
    end

    def inject_method_name
      @inject_method_name ||= "#{role_name}_inject"
    end

    def method_missing(name, *args, &block)
      if @base_model.respond_to?(name)
        inject(@base_model.send(name, *args, &block))
      else
        super
      end
    end
  end
end
