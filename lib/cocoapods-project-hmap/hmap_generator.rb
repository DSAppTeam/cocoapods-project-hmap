# !/usr/bin/env ruby

module ProjectHeaderMap
  class HmapGenerator
    QUOTE = 1 # 001
    ANGLE_BRACKET = 2 # 010
    BOTH = 3 # 011
    def initialize
      @hmap = Hash.new
    end
    # header_mapping : [Hash{FileAccessor => Hash}] Hash of file accessors by header mappings.
    def add_hmap_with_header_mapping(header_mapping, type, target_name=nil, module_name=nil)
      header_mapping.each do |facc, headers|
        headers.each do |key, value|
          value.each do |path|
            pn = Pathname.new(path)
            name = pn.basename.to_s
            dirname = pn.dirname.to_s + '/'
            # construct hmap hash info
            path_info = Hash['suffix' => name, 'prefix' => dirname]
            if type & QUOTE > 0
              # import with quote
              @hmap[name] = path_info
            end
            if type & ANGLE_BRACKET > 0
              if target_name != nil
                # import with angle bracket
                @hmap["#{target_name}/#{name}"] = path_info
              end
              if module_name != nil && module_name != target_name
                @hmap["#{module_name}/#{name}"] = path_info
              end
            end
          end
        end
      end
    end
    # @path : path/to/xxx.hmap
    # @return : succeed
    def save_to(path)
      if path != nil && @hmap.empty? == false
        pn=Pathname(path)
        json_path=pn.dirname.to_s + '/' + 'temp.json'
        # write hmap json to file
        File.open(json_path, 'w') { |file| file << @hmap.to_json }
        # json to hmap
        suc=system("hmap convert #{json_path} #{path}")
        # delete json file
        File.delete(json_path)
        suc
      else
        false
      end
    end
    def empty?
      @hmap.empty?
    end
  end
end
