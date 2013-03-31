require 'active_support/concern'

module Katakuchi::Role
  extend ActiveSupport::Concern

  module ClassMethods
    def actor(model)
      @base_model = model
    end

    def inject(instance_or_relation)
      return instance_or_relation unless injectable?(instance_or_relation)

      if instance_or_relation.kind_of?(@base_model)
        return inject_to_instance(instance_or_relation)
      end

      if instance_or_relation === Array
        return inject_to_array(inject_to_relation)
      end

      inject_to_relation(instance_or_relation)
    end

    def inject_to_instance(instance)
      instance.extend(self)
    end

    def inject_to_array(array)
      array.map do |obj|
        inject(obj)
      end
    end

    def instance_or_relation(relation)
      if injectable?(relation)
        relation.singleton_class.class_eval(<<-EOF)
          def to_a_with_#{alias_method_name}
            to_a_without_#{alias_method_name}.tap do |array|
              #{self.name}.inject(array)
            end
          end

          alias_method_chain :to_a, :#{alias_method_name}
        EOF
      end

      return relation
    end

    def injectable?(relation)
      (
        relation.kind_of?(@base_model) ||
        (
          defined?(ActiveRecord) &&
          relation.is_a?(ActiveRecord::Relation) &&
          !relation.respond_to?(alias_method_name)
        )
      )
    end

    private

    def alias_method_name
      @alias_method_name ||= :"role_inject_#{self.name}"
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
