# !/usr/bin/env ruby

module Pod
  class Installer
    class PostInstallHooksContext
      attr_accessor :aggregate_targets
      version = Gem::Version.new(Pod::VERSION)
      if version < Gem::Version.new('1.7.0')
        # Method `generate` has two args
        class << self
          alias old_generate generate
          def generate(sandbox, aggregate_targets)
            context = old_generate(sandbox, aggregate_targets)
            UI.info "- generate method of post install hook context hooked"
            context.aggregate_targets = aggregate_targets
            context
          end
        end
      elsif version < Gem::Version.new('1.10.0')
        # Method `generate` has three args
        class << self
          alias old_generate generate
          def generate(sandbox, pods_project, aggregate_targets)
            context = old_generate(sandbox, pods_project, aggregate_targets)
            UI.info "- generate method of post install hook context hooked"
            context.aggregate_targets = aggregate_targets
            context
          end
        end
      else
        # PostInstallHooksContext inherit BaseContext, just override `generate`
        def self.generate(sandbox, pods_project, aggregate_targets)
          context = super
          UI.info "- generate method of post install hook context override"
          context.aggregate_targets = aggregate_targets
          context
        end
      end
    end
  end
end
