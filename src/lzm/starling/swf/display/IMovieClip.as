package lzm.starling.swf.display
{
	/**
	 * 动画的元件接口 
	 * @author taojiang
	 * 
	 */	
	public interface IMovieClip
	{
		function update():void;									//每帧更新的函数
		function play():void;									//开始播放动画
		function stop(stopChild:Boolean = false):void;					//停止动画播放
	}
}