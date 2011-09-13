require 'sidekick/target'
require 'sidekick/reload'

class ActiveRecord::Base
  attr_accessor :_parent_record_set

  def reload_with_kick(*)
    self._parent_record_set = nil
    reload_without_kick
  end

  alias_method_chain :reload, :kick

  module Destructor
    def destroy(*)
      self._parent_record_set = nil
      super
    end
  end
  include Destructor

  [:clone, :dup].each do |method_name|
    define_method(:"#{method_name}_with_kick") do
      obj = send("#{method_name}_without_kick")
      obj._parent_record_set = nil
      obj
    end

    alias_method_chain method_name, :kick
  end

end

class ActiveRecord::Relation
  def to_a_with_kick
    records = to_a_without_kick
    records.each {|r| r._parent_record_set = records }
    records
  end

  alias_method_chain :to_a, :kick
end

[
  ActiveRecord::Associations::BelongsToAssociation,
  ActiveRecord::Associations::HasManyAssociation,
  ActiveRecord::Associations::BelongsToPolymorphicAssociation,
  ActiveRecord::Associations::HasOneAssociation,
  ActiveRecord::Associations::HasOneThroughAssociation,
  ActiveRecord::Associations::HasManyThroughAssociation
].each do |association_klass|
  association_klass.send :include, Sidekick::Target
end

[
  ActiveRecord::Associations::HasManyAssociation,
  ActiveRecord::Associations::HasManyThroughAssociation
].each do |association_klass|
  association_klass.send :include, Sidekick::Reload
end

class ActiveRecord::Associations::HasManyThroughAssociation
  module KickPreloadCheck
    def skip_kick_preload?
      super || !target_reflection_has_associated_record?
    end
  end
  include KickPreloadCheck
end
