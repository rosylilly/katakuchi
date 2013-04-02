require 'active_support/concern'

module Katakuchi::Role
  extend ActiveSupport::Concern

  module ClassMethods
    def actor(model)
      @base_model = model
    end

    def inject(instance_or_relation)
      return nil if instance_or_relation.nil?

      case instance_or_relation
      when Array then inject_with_array(instance_or_relation)
      when ActiveRecord::Relation then inject_with_relation(instance_or_relation)
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
      unless relation.respond_to?(:"to_a_with_#{inject_method_name}")
        (class << relation; end).class_eval(<<-EOF)
          def to_a_with_#{inject_method_name}(*args)
            to_a_without_#{inject_method_name}(*args).tap do |relation|
              #{self.name}.inject(relation)
            end
          end

          alias_method_chain :to_a, :#{inject_method_name}
        EOF
      end

      return relation
    end

    def inject_with_instance(obj)
      unless obj.is_a?(self)
        obj.extend(self)
      end

      return obj
    end

    private

    def role_name
      @role_name ||= self.name.to_s.underscore
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
