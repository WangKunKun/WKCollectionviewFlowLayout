Pod::Spec.new do |s|
s.name         = "WKCVMoveFlowLayout" # 项目名称
s.version      = "1.0.1"        # 版本号 与 你仓库的 标签号 对应
s.license      = "MIT"          # 开源证书
s.summary      = "实现cell可自由拖动的collectionview的flowlayout" # 项目简介

s.homepage     = "https://github.com/WangKunKun" # 你的主页
s.source       = { :git => "https://github.com/WangKunKun/WKCollectionviewFlowLayout.git", :tag => "#{s.version}" }#你的仓库地址，不能用SSH地址
s.source_files = "WKCVMoveFlowLayout" 
s.requires_arc = true # 是否启用ARC
s.platform     = :ios, "7.0" #平台及支持的最低版本
s.frameworks   = "UIKit", "Foundation" #支持的框架
# s.dependency   = "AFNetworking" # 依赖库

# User
s.author             = { "Wangkunkun" => "357863248@qq.com" } # 作者信息
s.social_media_url   = "https://wangkunkun.github.io/" # 个人主页

end
