# !/usr/bin/env ruby
# built-in black list pods
# you can use hmap_black_pod_list to add other pods
$hmap_black_pod_list = []

$strict_mode = false
$prebuilt_hmap_for_pod_targets = true

module Pod
  class Podfile
      module DSL
          def set_hmap_black_pod_list(pods)
            if pods != nil && pods.size() > 0
              $hmap_black_pod_list.concat(pods)
            end
          end
          # if use strict mode, main project can only use `#import <PodTargetName/SomeHeader.h>`
          # `#import <SomeHeader.h>` will get 'file not found' error
          # as well as PodTarget dependent on other PodTarget
          def set_hmap_use_strict_mode
            $strict_mode = true
          end
          # turn off prebuilt hmap for targets in pod project except the `main` target
          def turn_prebuilt_hmap_off_for_pod_targets
            $prebuilt_hmap_for_pod_targets = false
          end
      end
  end
end
