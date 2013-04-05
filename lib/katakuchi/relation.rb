module Katakuchi
  class Relation
    def initialize(source, role)
      @source = source
      @role = role
    end

    private

    def method_missing(name, *args, &block)
      if @source.respond_to?(name)
        @role.inject(@source.send(name, *args, &block))
      else
        super
      end
    end
  end
end
