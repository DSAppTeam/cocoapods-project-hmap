# !/usr/bin/env ruby

require 'cocoapods-project-hmap/podfile_dsl'
require 'cocoapods-project-hmap/pod_target'
require 'cocoapods-project-hmap/post_install_hook_context'

module ProjectHeaderMap
  Pod::HooksManager.register('cocoapods-project-hmap', :post_install) do |post_context|
    generate_type = $strict_mode ? HmapGenerator::ANGLE_BRACKET : HmapGenerator::BOTH
    hmaps_dir=post_context.sandbox_root +  '/prebuilt-hmaps'
    unless File.exist?(hmaps_dir)
        Dir.mkdir(hmaps_dir)
    end

    post_context.aggregate_targets.each do |one|
      pods_hmap = HmapGenerator.new
      Pod::UI.message "- hanlding headers of aggregate target :#{one.name}".green
      one.pod_targets.each do |target|
        Pod::UI.message "- hanlding headers of target :#{target.name}"
        pods_hmap.add_hmap_with_header_mapping(target.public_header_mappings_by_file_accessor, generate_type, target.name, target.product_module_name)
        unless $hmap_black_pod_list.include?(target.name) || $prebuilt_hmap_for_pod_targets == false
          target_hmap = HmapGenerator.new
          # set project header for current target
          target_hmap.add_hmap_with_header_mapping(target.header_mappings_by_file_accessor, HmapGenerator::BOTH, target.name, target.product_module_name)
          if target.respond_to?(:recursively_add_dependent_headers_to_hmap)
            target.recursively_add_dependent_headers_to_hmap(target_hmap, generate_type)
          end

          target_hmap_name="#{target.name}.hmap"
          target_hmap_path = hmaps_dir + "/#{target_hmap_name}"
          relative_hmap_path = "prebuilt-hmaps/#{target_hmap_name}"
          if target_hmap.save_to(target_hmap_path)
            target.reset_header_search_with_relative_hmap_path(relative_hmap_path)
          end
        else
          Pod::UI.message "- skip handling headers of target :#{target.name}"
        end
      end

      pods_hmap_name = "#{one.name}.hmap"
      pods_hmap_path = hmaps_dir + "/#{pods_hmap_name}"
      relative_hmap_path = "prebuilt-hmaps/#{pods_hmap_name}"
      if pods_hmap.save_to(pods_hmap_path)
        # override xcconfig
        one.reset_header_search_with_relative_hmap_path(relative_hmap_path)
      end
    end
  end
end
