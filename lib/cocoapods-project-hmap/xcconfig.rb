# !/usr/bin/env ruby

module Xcodeproj
  class Config
    def remove_attr_with_key(key)
      unless key == nil
        @attributes.delete(key)
      end
    end
    def remove_header_search_path(prebuilt_hmap_target_names=nil)
      header_search_paths = @attributes['HEADER_SEARCH_PATHS']
      if header_search_paths
        new_paths = Array.new
        header_search_paths.split(' ').each do |p|
          if p.include?('${PODS_ROOT}/Headers') == false or p.end_with?('/Private"') or p.end_with?('/Public"')
            # retain path not in normal `pod headers` path
            # and "${PODS_ROOT}/Headers/Private" "${PODS_ROOT}/Headers/Public"
            new_paths << p
          elsif prebuilt_hmap_target_names != nil && prebuilt_hmap_target_names.empty? == false
            # add path not prebuilt hmap
            if prebuilt_hmap_target_names.select { |name| p.include?(name) }.empty?
              new_paths << p
            end
          end
        end
        if new_paths.size > 0
          @attributes['HEADER_SEARCH_PATHS'] = new_paths.join(' ')
        else
          remove_attr_with_key('HEADER_SEARCH_PATHS')
        end
      end
      remove_system_option_in_other_cflags
    end
    def remove_system_option_in_other_cflags
      flags = @attributes['OTHER_CFLAGS']
      if flags
        new_flags = ''
        skip = false
        flags.split(' ').each do |substr|
          if skip
            skip = false
            next
          end
          if substr == '-isystem'
            skip = true
            next
          end
          if new_flags.length > 0
            new_flags += ' '
          end
          new_flags += substr
        end
        if new_flags.length > 0
          @attributes['OTHER_CFLAGS'] = new_flags
        else
          remove_attr_with_key('OTHER_CFLAGS')
        end
      end
    end
    def reset_header_search_with_relative_hmap_path(hmap_path, white_list=nil)
      # remove all search paths
      remove_header_search_path(white_list)
      # add build flags
      new_paths = Array["${PODS_ROOT}/#{hmap_path}"]
      header_search_paths = @attributes['HEADER_SEARCH_PATHS']
      if header_search_paths
        new_paths.concat(header_search_paths.split(' '))
      end
      @attributes['HEADER_SEARCH_PATHS'] = new_paths.join(' ')
    end
    def set_use_hmap(use=false)
      @attributes['USE_HEADERMAP'] = (use ? 'YES' : 'NO')
    end
  end
end
