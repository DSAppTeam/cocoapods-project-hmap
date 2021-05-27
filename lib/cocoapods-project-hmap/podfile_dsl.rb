# !/usr/bin/env ruby
# built-in black list pods (long import path not supported
# you can use hmap_black_pod_list to add other pods
$hmap_black_pod_list = [
  'GoogleUtilities',
  'MeshPipe',
  'GoogleDataTransport',
  'FirebaseCoreDiagnostics',
  'FirebaseCore',
  'FirebaseCrashlytics',
  'FirebaseInstallations',
  'CoreDragon',
  'Objective-LevelDB'
]
# if use strict mode, main project can only use `#import <PodTargetName/SomeHeader.h>`
# `#import <SomeHeader.h>` will get 'file not found' error
# as well as PodTarget dependent on other PodTarget
$strict_mode = false

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
      end
  end
end
