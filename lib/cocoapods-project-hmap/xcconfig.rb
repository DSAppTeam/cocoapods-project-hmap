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
          unless search_path_should_be_deleted?(p, prebuilt_hmap_target_names)
            new_paths << p
          end
        end
        if new_paths.size > 0
          @attributes['HEADER_SEARCH_PATHS'] = new_paths.join(' ')
        else
          remove_attr_with_key('HEADER_SEARCH_PATHS')
        end
      end
      remove_system_option_in_other_cflags(prebuilt_hmap_target_names)
    end
    def search_path_should_be_deleted?(search_path, prebuilt_hmap_target_names=nil)
      # Check if the path should be deleted from search list
      # 1. It must be at the ${PODS_ROOT} directory
      # 2. It has generated hmap
      ret = false
      if search_path.include?('${PODS_ROOT}/Headers')
        if prebuilt_hmap_target_names
           ret = prebuilt_hmap_target_names.select { |name| search_path.include?(name) }.empty? == false
        end
      end
      ret
    end
    def remove_system_option_in_other_cflags(prebuilt_hmap_target_names=nil)
      # ----------------------------------------------
      # -I<dir>, --include-directory <arg>, --include-directory=<arg>
      # Add directory to include search path. For C++ inputs, if there are multiple -I options,
      # these directories are searched in the order they are given before the standard system directories are searched.
      # If the same directory is in the SYSTEM include search paths, for example if also specified with -isystem, the -I option will be ignored
      #
      # -isystem<directory>
      # Add directory to SYSTEM include search path
      # ----------------------------------------------
      flags = @attributes['OTHER_CFLAGS']
      if flags
        new_flags = ''
        is_isystem_flag = false
        flags.split(' ').each do |substr|
          append_str = substr
          # Previous flag is `isystem`
          if is_isystem_flag
            is_isystem_flag = false
            if search_path_should_be_deleted?(append_str, prebuilt_hmap_target_names)
              next
            else
              # recover
              append_str = "-isystem #{append_str}"
            end
          end

          if append_str == '-isystem'
            is_isystem_flag = true
            next
          end

          if new_flags.length > 0
            new_flags += ' '
          end
          new_flags += append_str
        end

        if new_flags.length > 0
          @attributes['OTHER_CFLAGS'] = new_flags
        else
          remove_attr_with_key('OTHER_CFLAGS')
        end
      end
    end
    def reset_header_search_with_relative_hmap_path(hmap_path, prebuilt_hmap_target_names=nil)
      # Delete associate search paths
      remove_header_search_path(prebuilt_hmap_target_names)
      # Add hmap file to search path
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
