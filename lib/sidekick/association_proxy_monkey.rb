# Please remove me as soon as you can - __FILE__

class ActiveRecord::Associations::AssociationProxy
  def load
    load_target unless loaded?
    self unless @target.nil?
  end

  def reload
    reset
    load
  end
end

module Sidekick
  module MonkeyAssociationAccessor
    def association_accessor_methods(reflection, association_proxy_class)
      super(reflection, association_proxy_class)

      redefine_method(reflection.name) do |*params|
        force_reload = params.first unless params.empty?
        association = association_instance_get(reflection.name)

        if association.nil? || force_reload
          association = association_proxy_class.new(self, reflection)
          retval = force_reload ? reflection.klass.uncached { association.reload } : association.load
          if retval.nil? and association_proxy_class == BelongsToAssociation
            association_instance_set(reflection.name, nil)
            return nil
          end
          association_instance_set(reflection.name, association)
        end

        association.target.nil? ? nil : association
      end

    end
  end
end

ActiveRecord::Base.send :extend, Sidekick::MonkeyAssociationAccessor
