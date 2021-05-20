# cocoapods-project-hmap

此项目思路源自美团分享的文章：[《一款可以让大型iOS工程编译速度提升50%的工具》](https://tech.meituan.com/2021/02/25/cocoapods-hmap-prebuilt.html)，由于该插件未开源，所以研究了下，通过hook post_install生成hmap文件保存到pod项目根目录，然后修改xcconfig文件，增加OTHER_CFLAGS，删除HEADER_SEARCH_PATHS，使得编译过程直接使用hmap文件。

## 效果

在我们自己的项目中测试一次全量编译数据为：

| before | hmap |
| ------ | ---- |
| 471s   | 330s | 

> 数据测试环境：
> - Mac：Mac mini (2018) / 3.2 GHz 六核Intel Core i7 / 16 GB 2667 MHz DDR4
> - Xcode: 12.4
> - ruby: 2.6.0
> - cocoapods: 1.10.1

从测试效果可以看出还是有较大提升的，所以开源出来给大家使用一下，可以在 issue 中反馈一下，也可以通过邮箱：chenxGen@outlook.com 联系我。

## 安装

由于hmap文件的生成借助于开源项目[hmap](https://github.com/milend/hmap)，请先通过`brew install milend/taps/hmap`安装

### 使用Gemfile:

如果你的项目使用bundler管理gems，则在你的Gemfile中加入：
```ruby
gem 'cocoapods-project-hmap'
```

### 源码编译:

```shell
$ git clone https://github.com/chenxGen/cocoapods-project-hmap.git
$ cd  cocoapods-project-hmap
$ gem build cocoapods-project-hmap.gemspec
$ sudo gem install cocoapods-project-hmap-0.0.2.gem
```

## 使用

在你的Podfile中加入这一行: `plugin 'cocoapods-project-hmap'`
