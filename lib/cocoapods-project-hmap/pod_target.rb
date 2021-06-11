# !/usr/bin/env ruby
require 'cocoapods-project-hmap/xcconfig'

module Pod
  class PodTarget
    def reset_header_search_with_relative_hmap_path(hmap_path)
      if build_settings.instance_of?(Hash)
        build_settings.each do |config_name, setting|
          config_file = setting.xcconfig
          config_file.reset_header_search_with_relative_hmap_path(hmap_path)
          # https://github.com/CocoaPods/CocoaPods/issues/1216
          # just turn off private xcconfig's USE_HEADERMAP flag
          config_file.set_use_hmap(false)
          config_path = xcconfig_path(config_name)
          config_file.save_as(config_path)
        end
      elsif build_settings.instance_of?(BuildSettings::PodTargetSettings)
        config_file = build_settings.xcconfig
        config_file.reset_header_search_with_relative_hmap_path(hmap_path)
        # https://github.com/CocoaPods/CocoaPods/issues/1216
        # just turn off private xcconfig's USE_HEADERMAP flag
        config_file.set_use_hmap(false)
        config_path = xcconfig_path
        config_file.save_as(config_path)
      else
        puts 'Unknown build settings'.red
      end
    end
  end
  class AggregateTarget
    def reset_header_search_with_relative_hmap_path(hmap_path)
      # override xcconfig
      xcconfigs.each do |config_name, config_file|
        config_file.reset_header_search_with_relative_hmap_path(hmap_path)
        config_path = xcconfig_path(config_name)
        config_file.save_as(config_path)
      end
    end
  end
end
