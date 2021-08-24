# !/usr/bin/env ruby
require 'cocoapods-project-hmap/xcconfig'
require 'cocoapods-project-hmap/hmap_generator'

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
    def recursively_add_dependent_headers_to_hmap(hmap, generate_type)
      dependent_targets.each do |depend_target|
        # set public header for dependent target
        hmap.add_hmap_with_header_mapping(depend_target.public_header_mappings_by_file_accessor, generate_type, depend_target.name, depend_target.product_module_name)
        depend_target.recursively_add_dependent_headers_to_hmap(hmap, generate_type)
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
