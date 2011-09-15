module Sidekick
  module Target
    def self.included(base)
      base.send :alias_method_chain, :find_target, :kick
    end

    def find_target_with_kick
      return find_target_without_kick if skip_kick_preload? || !@owner._parent_record_set

      reflection_name = @reflection.name

      # Fucking STI
      working_record_set = @owner._parent_record_set.find_all {|r| r.class.reflect_on_association(reflection_name) }.uniq

      # Sorry new records. You don't belong.
      working_record_set.each do |r|
        x = r.send(:instance_variable_get, "@#{reflection_name}")
        x.reset if x
      end

      @owner.class.send(:preload_associations, working_record_set, reflection_name.to_sym)

      record_set = working_record_set.map do |r|
        x = r.send(:instance_variable_get, "@#{reflection_name}")
        x.target if x
      end

      if record_set.present?
        record_set.flatten!
        record_set.compact!
      end

      record_set.each {|r| r._parent_record_set = record_set }

      associtaion = @owner.send(:instance_variable_get, "@#{reflection_name}")
      associtaion.target if associtaion
    end

    def skip_kick_preload?
      skip_keys = [:finder_sql, :order, :conditions, :uniq, :limit]
      skip_keys.any? {|key| @reflection.options.has_key?(key) }
    end
  end
end
