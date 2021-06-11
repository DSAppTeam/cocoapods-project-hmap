# cocoapods-project-hmap

A cocoapods plugin to improve compilation speed at preprosessor phase by using hmap instead of file paths for header searching. The idea comes from [《一款可以让大型iOS工程编译速度提升50%的工具》](https://tech.meituan.com/2021/02/25/cocoapods-hmap-prebuilt.html)

## Benchmark

There are some test cases in the benchmark project : [hmap-benchmark](https://github.com/chenxGen/hmap-benchmark/).

The latest outputs by running `run_benchmark.rb` are:

- Mac mini (Intel i7/16g) :

  ```
  +--------------------------------------+--------------------+------------------------------------------------------------------------------------------------------------------------+
  | Case                                 | Average(s)         | Detail(s)                                                                                                              |
  +--------------------------------------+--------------------+------------------------------------------------------------------------------------------------------------------------+
  | 100 source files & 125 pods (origin) | 192.43606980641684 | [218.57447242736816, 178.7542200088501, 179.97951698303223]                                                            |
  | 100 source files & 125 pods (plugin) | 165.76690363883972 | [166.8555600643158, 165.40182876586914, 165.04332208633423]                                                            |
  | > optimization (speed)               | 16.09%             |                                                                                                                        |
  | > optimization (time cost)           | 13.86%             |                                                                                                                        |
  | 1 source files & 125 pods (origin)   | 170.00553512573242 | [175.31463813781738, 173.79285717010498, 160.9091100692749]                                                            |
  | 1 source files & 125 pods (plugin)   | 124.49473492304485 | [123.54309391975403, 124.4949209690094, 125.4461898803711]                                                             |
  | > optimization (speed)               | 36.56%             |                                                                                                                        |
  | > optimization (time cost)           | 26.77%             |                                                                                                                        |
  | Total (origin)                       | 181.22080246607462 | [218.57447242736816, 178.7542200088501, 179.97951698303223, 175.31463813781738, 173.79285717010498, 160.9091100692749] |
  | Total (plugin)                       | 145.1308192809423  | [166.8555600643158, 165.40182876586914, 165.04332208633423, 123.54309391975403, 124.4949209690094, 125.4461898803711]  |
  | > optimization (speed)               | 24.87%             |                                                                                                                        |
  | > optimization (time cost)           | 19.91%             |                                                                                                                        |
  +--------------------------------------+--------------------+------------------------------------------------------------------------------------------------------------------------+
  ```
- Mac air (Apple M1/16g) :

  ```
  +--------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------+
  | Case                                 | Average(s)        | Detail(s)                                                                                                          |
  +--------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------+
  | 100 source files & 125 pods (origin) | 95.07198365529378 | [91.36949586868286, 96.10968923568726, 97.73676586151123]                                                          |
  | 100 source files & 125 pods (plugin) | 91.2074584166289  | [90.87663986448735, 90.77357686752014, 91.97326111793518]                                                          |
  | > optimization (speed)               | 4.24%             |                                                                                                                    |
  | > optimization (time cost)           | 4.06%             |                                                                                                                    |
  | 1 source files & 125 pods (origin)   | 81.564133644104   | [80.95829105377197, 82.07278513988386, 81.66132473945618]                                                          |
  | 1 source files & 125 pods (plugin)   | 79.28314812668217 | [78.21958923339844, 80.21097787748413, 79.17887886892395]                                                          |
  | > optimization (speed)               | 2.98%             |                                                                                                                    |
  | > optimization (time cost)           | 2.89%             |                                                                                                                    |
  | Total (origin)                       | 88.3180586496989  | [91.36949586868286, 96.10968923568726, 97.73676586151123, 80.95829105377197, 82.07278513988386, 81.66132473945618] |
  | Total (plugin)                       | 85.2053037/161153 | [90.87663986448735, 90.77357686752014, 91.97326111793518, 78.21958923339844, 80.21097787748413, 79.17887886892395] |
  | > optimization (speed)               | 3.65%             |                                                                                                                    |
  | > optimization (time cost)           | 3.52%             |                                                                                                                    |
  +--------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------+
  ```

The outputs indicate that this plugin has about 3%-36% build speed improvement, the improvement is not significant on mac using M1 processor because of Apple M1 processor's high IO performance (I GUESS...).

**So if you are using Mac with Apple M1 processor, There may be no need to use this plugin.**

## Requirement

- CocoaPods Version: `>=1.7.0`
- Install command line tool [hmap](https://github.com/milend/hmap) : `brew install milend/taps/hmap`

## Installation

- With Gemfile : Add this line to your `Gemfile` : `gem 'cocoapods-project-hmap'`
- With CommandLine : `sudo gem install cocoapods-project-hmap`

## Usage

In your `Podfile`, add this line : `plugin 'cocoapods-project-hmap'`

And this plugin also provides Podfile DSL bellow:

- `set_hmap_black_pod_list`: There are some unsolved situation in develping this plugin, such as a 'pod' using a long path import in their code, like `#import "a/very/very/long/path/to/header.h"`, I did not think of a suitable strategy to handle this, so I provide a method to adding then to black list, you can add then with code `set_hmap_black_pod_list(['PodA','PodB'])`, and there are some built-in 'pod' in black list, see : [built-in black list](/lib/cocoapods-project-hmap/podfile_dsl.rb). And if you have some other build error because of this plugin, adding then to black list...
- `turn_prebuilt_hmap_off_for_pod_targets`: If you have to many build error after using this plugin, or have to add to many 'pod' to black list, I provides a most non-intrusive way to use, call this method `turn_prebuilt_hmap_off_for_pod_targets` to ignore hmap prebuilt for most of the pod target (excepting the 'main' pods, named `Pods-${YOUR SCHEME}`).
- `set_hmap_use_strict_mode`: Import a header in other library(PodA), strictly speaking, we should use `#import <PodA/Header.h>`, but not all library developer do like that, if you turn it on, you can find then.

The code in your Podfile may look like that in the end :

```ruby
platform :ios, '10.0'
plugin 'cocoapods-project-hmap'
set_hmap_black_pod_list(['PodA','PodB'])
turn_prebuilt_hmap_off_for_pod_targets
#set_hmap_use_strict_mode(true)

target 'app' do
  pod 'PodA'
  ...
  pod 'PodB'
end
```

## Contact

Your can contact me on [Twitter](http://twitter.com/chenxGen).

## License

cocoapods-project-hmap is released under the MIT license. See LICENSE for details.
