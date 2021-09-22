# cocoapods-project-hmap

此插件思路来源于[《一款可以让大型iOS工程编译速度提升50%的工具》](https://tech.meituan.com/2021/02/25/cocoapods-hmap-prebuilt.html)。通过使用 header map (以下简称 hmap ) 代替文件路径搜索优化预处理阶段中头文件搜索的性能实现编译速度提升。

[English](./README_en.md)

## 首先，什么样的项目适合使用这个插件？

1. **仅适合使用 objective-c 作为主要开发语言项目**，因为 swift 没有头文件的概念，从其编译原理上看并没有什么帮助；
2. **不适合 Podfile 中 开启了 `use_frameworks!` or `use_modular_headers!` 的项目使用**，由于为了兼容 clang module 特性，采取的策略是不对开启了 DEFINES_MODULE 的项目生成 hmap；
3. **不适用于 CPU 为 M1 以及后续 M 系列芯片的 Mac**，因为使用之后提升也很小；

综上，比较适合 old school 的项目使用此插件，如果你的项目满足以上条件推荐使用此插件，不然可能收效甚微，不建议继续往下看了。

## 插件名的由来

最初版本的插件仅仅为了给 Pod Project 和 Host Project 提供一个可行的跨项目 hmap 方案，填补 Xcode 自带的仅支持 Project 内部的 hmap 的空白，由此得名：cocoapods-project-hmap.

## 环境要求

- CocoaPods Version: `>=1.7.0`
- 安装命令行工具 [hmap](https://github.com/milend/hmap) : `brew install milend/taps/hmap`

## 安装

- 使用Gemfile : 在你的 `Gemfile` 中添加: `gem 'cocoapods-project-hmap'`
- 通过命令行安装 : `sudo gem install cocoapods-project-hmap`

## 使用

只需要在你的`Podfile`中调用：`plugin 'cocoapods-project-hmap'` 声明使用该插件。

同时插件还为`Podfile`提供了一下几个可选的方法调用：

- **set_hmap_black_pod_list:** 开发插件的时候发现有些Pod target使用预生成的hmap编译会出错，比如使用了`#import "a/very/very/long/path/to/header.h"`，暂时没想到好的解决方案，所以针对这种情况需要手动添加到黑名单，不对该target的进行处理，如：`set_hmap_black_pod_list(['PodA','PodB'])`，插件内置了一些这种情况的三方库，具体见：[built-in black list](/lib/cocoapods-project-hmap/podfile_dsl.rb)。如果你还有其他的三方库由于其他原因编译失败，也可以把它添加到黑名单。。。

- **turn_prebuilt_hmap_off_for_pod_targets:** 如果你发现有太多的三方库需要添加到黑名单，你可以直接通过调用这个方法开启“纯净模式”，关闭插件对Pod Project内部所有target的header处理，仅仅对提供给主项目使用的target处理hmap

- **set_hmap_use_strict_mode:** 在一个target中引用另一个target的header，严格意义上来说应该使用`#import <PodA/Header.h>`的方式，但是有些是通过`#import "Header.h"`，这种情况如果设置了对应的header search path编译是可以成功的，比如使用原生的cocoapods情况下，在项目中使用`#import "Masonry.h"`、`#import <Mansory.h>`和`#import <Masonry/Mansory.h>`三种方式引入都是可以成功的，如果你使用这个插件并且开启这个选项后只有`#import <Masonry/Mansory.h>`可以编译成功。默认为关闭。


最终你的Podfile看起来会是这样的 :

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

## 联系方式

QQ: 930565063

## License

cocoapods-project-hmap is released under the MIT license. See LICENSE for details.
