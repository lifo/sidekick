module Sidekick
  module Target
    def self.included(base)
      base.send :alias_method_chain, :find_target, :kick
    end

    def find_target_with_kick
      return find_target_without_kick if skip_kick_preload? || !@owner._parent_record_set

      reflection_name = @reflection.name

      # Fucking STI
      working_record_set = @owner._parent_record_set.find_all {|r| r.class.reflect_on_association(reflection_name) }

      ActiveRecord::Associations::Preloader.new(working_record_set, reflection_name).run

      record_set = working_record_set.map do |r|
        x = r.association(reflection_name)
        x.target if x
      end

      if record_set.present?
        record_set.flatten!
        record_set.compact!
      end

      record_set.each {|r| r._parent_record_set = record_set }

      association = @owner.association(reflection_name)

      if association
        # [] is to prevent double merge for one-many associations
        association.target.is_a?(Array) ? [] : association.target
      end
    end

    def skip_kick_preload?
      skip_keys = [:finder_sql, :order, :conditions, :uniq, :limit]
      skip_keys.any? {|key| @reflection.options.has_key?(key) }
    end
  end
end
