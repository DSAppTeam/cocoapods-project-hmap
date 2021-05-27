# !/usr/bin/env ruby

module Pod
  class Installer
    class PostInstallHooksContext
      attr_accessor :aggregate_targets
      def self.generate(sandbox, pods_project, aggregate_targets)
        context = super
        UI.info "- generate method of post install hook context override"
        context.aggregate_targets = aggregate_targets
        context
      end
    end
  end
end
