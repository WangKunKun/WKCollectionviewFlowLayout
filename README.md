# WKCollectionViewFlowLayout 






####**[效果展示](http://wangkunkun.github.io/iOS/wkcollectionviewflowlayout.html)**


####**特点**####

1. 功能

	**简介：实现了cell可拖动功能的flowlaout**
	
	- cell拖动范围自由定制（同组拖动，跨组拖动，某组不能拖动）
	- 可设置指定cell不可被拖动不可被交换
	- cell拖动到section中空白无cell处后自动插入(开关isAutoInsert，默认关闭)
	- cell拖动处collecitonview有效区域自动删除(开关 isAutoDelete,默认关闭)
	- 拖动cell时至屏幕需翻页且可翻页时自动滚动 
		
2. 高度监控

	- 利用代理模式，提供了一系列的方法实时监控Cell的布局位置和数据位置
	
	
3. 高度方便定制
		
		仅需通过配置CollectionViewStyle.plist文件可迅速定制CollectionView布局的一系列的属性如：
		MaximumEffectiveRangeOfAutoScroll 触发自动滚动的范围
		SectionSpacing 分组间距
		ItemSpacing cell间距
		LineSpacing 行/列间距
		CellSize	Cell的宽高
		Insets		CollectionView中Cell与边框的距离
		VORH		CollectionView中流式布局的方式-行/列
		
		
		


		