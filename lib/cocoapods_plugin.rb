# !/usr/bin/env ruby

require 'cocoapods-project-hmap/podfile'
require 'cocoapods-project-hmap/pod_target'
require 'cocoapods-project-hmap/post_install_hook_context'
require 'cocoapods-project-hmap/hmap_generator'

module ProjectHeaderMap
  Pod::HooksManager.register('cocoapods-project-hmap', :post_install) do |post_context|
    generate_type = $strict_mode ? HmapGenerator::ANGLE_BRACKET : HmapGenerator::BOTH
    post_context.aggregate_targets.each do |one|
      pods_hmap = HmapGenerator.new
      Pod::UI.puts "- hanlding headers of aggregate target :#{one.name}".green
      one.pod_targets.each do |target|
        Pod::UI.puts "  - hanlding headers of target :#{target.name}"
        pods_hmap.add_hmap_with_header_mapping(target.public_header_mappings_by_file_accessor, generate_type, target.name)
        unless $hmap_black_pod_list.include?(target.name)
          target_hmap = HmapGenerator.new
          # set project header for current target
          target_hmap.add_hmap_with_header_mapping(target.header_mappings_by_file_accessor, HmapGenerator::BOTH, target.name)
          target.dependent_targets.each do |depend_target|
            # set public header for dependent target
            target_hmap.add_hmap_with_header_mapping(depend_target.public_header_mappings_by_file_accessor, generate_type, depend_target.name)
          end

          target_hmap_name="#{target.name}.hmap"
          target_hmap_path = post_context.sandbox_root + "/#{target_hmap_name}"
          if target_hmap.save_to(target_hmap_path)
            target.reset_header_search_with_hmap(target_hmap_name)
          end
        end
      end

      pods_hmap_name = "#{one.name}.hmap"
      pods_hmap_path = post_context.sandbox_root + "/#{pods_hmap_name}"
      if pods_hmap.save_to(pods_hmap_path)
        # override xcconfig
        one.reset_header_search_with_hmap(pods_hmap_name)
      end
    end
  end
end
