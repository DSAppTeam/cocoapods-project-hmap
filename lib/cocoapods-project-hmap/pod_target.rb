# !/usr/bin/env ruby
require 'cocoapods-project-hmap/xcconfig'
require 'cocoapods-project-hmap/hmap_generator'
require 'cocoapods-project-hmap/podfile_dsl'

SAVED_HMAP_DIR='prebuilt-hmaps'

module Pod
  class Target
    attr_accessor :prebuilt_hmap_target_names
    def save_hmap(hmap)
      if hmap.empty? == false
        target_hmap_name="#{name}.hmap"
        relative_hmap_path = "#{SAVED_HMAP_DIR}/#{target_hmap_name}"
        target_hmap_path = sandbox.root.to_s + "/#{relative_hmap_path}"
        hmaps_dir = sandbox.root.to_s + "/#{SAVED_HMAP_DIR}"
        unless File.exist?(hmaps_dir)
            Dir.mkdir(hmaps_dir)
        end
        if hmap.save_to(target_hmap_path)
          reset_header_search_with_relative_hmap_path(relative_hmap_path)
        end
      end
    end
    def add_prebuilt_hmap_target(name)
      @prebuilt_hmap_target_names = Array.new if @prebuilt_hmap_target_names == nil
      @prebuilt_hmap_target_names << name
    end
    def concat_prebuilt_hmap_targets(names)
      @prebuilt_hmap_target_names = Array.new if @prebuilt_hmap_target_names == nil
      @prebuilt_hmap_target_names.concat(names) if names
    end
  end

  class PodTarget
    def reset_header_search_with_relative_hmap_path(hmap_path)
      if build_settings.instance_of?(Hash)
        build_settings.each do |config_name, setting|
          config_file = setting.xcconfig
          config_file.reset_header_search_with_relative_hmap_path(hmap_path, @prebuilt_hmap_target_names.uniq)
          # https://github.com/CocoaPods/CocoaPods/issues/1216
          # just turn off private xcconfig's USE_HEADERMAP flag
          config_file.set_use_hmap(false)
          config_path = xcconfig_path(config_name)
          config_file.save_as(config_path)
        end
      elsif build_settings.instance_of?(BuildSettings::PodTargetSettings)
        config_file = build_settings.xcconfig
        config_file.reset_header_search_with_relative_hmap_path(hmap_path, @prebuilt_hmap_target_names.uniq)
        # https://github.com/CocoaPods/CocoaPods/issues/1216
        # just turn off private xcconfig's USE_HEADERMAP flag
        config_file.set_use_hmap(false)
        config_path = xcconfig_path
        config_file.save_as(config_path)
      else
        Pod::UI.notice 'Unknown build settings'
      end
    end
    def recursively_add_dependent_headers_to_hmap(hmap, generate_type)
      dependent_targets.each do |depend_target|
        # set public header for dependent target
        depend_target.generate_hmap(hmap, generate_type, true, true) if depend_target.respond_to?(:generate_hmap)
        concat_prebuilt_hmap_targets(depend_target.prebuilt_hmap_target_names) if depend_target.prebuilt_hmap_target_names
      end
    end

    def generate_hmap(hmap, generate_type, only_public_headers=true, add_dependency=false)
      # There is no need to add headers of target defines module to hmap.
      unless defines_module?
        unless $hmap_black_pod_list.include?(name)
          add_prebuilt_hmap_target(name)
          # Create hmap for current target if not in black list.
          hmap.add_hmap_with_header_mapping(only_public_headers ? public_header_mappings_by_file_accessor : header_mappings_by_file_accessor, generate_type, name, product_module_name)
          # Recursively add dependent targets if needed.
          recursively_add_dependent_headers_to_hmap(hmap, generate_type) if add_dependency
        else
          Pod::UI.message "- skip target in black list :#{name}"
        end
      end
    end
  end
  class AggregateTarget
    def reset_header_search_with_relative_hmap_path(hmap_path)
      # override xcconfig
      xcconfigs.each do |config_name, config_file|
        config_file.reset_header_search_with_relative_hmap_path(hmap_path, @prebuilt_hmap_target_names.uniq)
        config_path = xcconfig_path(config_name)
        config_file.save_as(config_path)
      end
    end
  end
end
