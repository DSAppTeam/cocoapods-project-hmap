# cocoapods-project-hmap

A cocoapods plugin to improve compilation speed at preprosessor phase by using hmap instead of file paths for header searching. The idea comes from [《一款可以让大型iOS工程编译速度提升50%的工具》](https://tech.meituan.com/2021/02/25/cocoapods-hmap-prebuilt.html)

## First

What kind of projects are recommended to use this plugin?

- **Project using objective-c as their main develop language**
- **Project not using `use_frameworks!` and `use_modular_headers!` in their Podfile**

and Developer not using Mac with M series CPU.

## Requirement

- CocoaPods Version: `>=1.7.0`
- Install command line tool [hmap](https://github.com/milend/hmap) : `brew install milend/taps/hmap`

## Installation

- With Gemfile : Add this line to your `Gemfile` : `gem 'cocoapods-project-hmap'`
- With CommandLine : `sudo gem install cocoapods-project-hmap`

## Usage

In your `Podfile`, add this line : `plugin 'cocoapods-project-hmap'`

And this plugin also provides Podfile DSL bellow:

- `set_hmap_black_pod_list`: If you have some compilation error for pod targets because of this plugin, adding the target name to black list...
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
