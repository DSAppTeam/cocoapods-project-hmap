# !/usr/bin/env ruby
require 'cocoapods-project-hmap/xcconfig'

module Pod
  class PodTarget
    def reset_header_search_with_hmap(hmap_name)
      build_settings.each do |config_name, setting|
        config_file = setting.xcconfig
        config_file.reset_header_search_with_hmap(hmap_name)
        xcconfig_path = xcconfig_path(config_name)
        config_file.save_as(xcconfig_path)
      end
    end
  end
  class AggregateTarget
    def reset_header_search_with_hmap(hmap_name)
      # override xcconfig
      xcconfigs.each do |config_name, config_file|
        config_file.reset_header_search_with_hmap(hmap_name)
        xcconfig_path = xcconfig_path(config_name)
        config_file.save_as(xcconfig_path)
      end
    end
  end
end
