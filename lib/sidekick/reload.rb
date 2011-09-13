module Sidekick
  module Reload
    def self.included(base)
      base.send :alias_method_chain, :reload, :kick
    end

    def reload_with_kick
      @owner._parent_record_set = nil
      reload_without_kick
    end
  end
end
