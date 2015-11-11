# WKCollectionViewFlowLayout 






####**[效果展示](http://wangkunkun.github.io/iOS/wkcollectionviewflowlayout.html)**


####**特点**####

1. 功能

		代码中实现了可对CollectionView中的Cell进行自由拖动，在拖动过程中会和其他Cell交换位置，并在拖动跨页时CollectionView会自动滚动，支持横向竖向。
		
2. 高度监控

		并借鉴于RACollectionViewReorderableTripletLayout利用代理模式，提供了一系列的方法实时监控Cell的布局位置和数据位置。
	
	
3. 高度方便定制
		
		仅需通过配置CollectionViewStyle.plist文件可迅速定制CollectionView布局的一系列的属性如：
		MaximumEffectiveRangeOfAutoScroll 触发自动滚动的范围
		SectionSpacing 分组间距（注item的拖动移位不支持跨分组）
		ItemSpacing cell间距
		LineSpacing 行/列间距
		CellSize	Cell的宽高
		Insets		CollectionView中Cell与边框的距离
		VORH		CollectionView中流式布局的方式-行/列
		
		
		


		