package lzm.starling.swf.display
{
	import com.coffeebean.swf.typeData.FrameChildData;
	import com.coffeebean.swf.typeData.FrameLabelData;
	import com.coffeebean.swf.typeData.SpriteData;
	
	import lzm.starling.swf.Swf;
	
	import starling.display.DisplayObject;
	import starling.events.Event;

	/**
	 * qb动画剪辑，子级显示对像只能是img或者是qb 
	 * @author taojiang
	 */	
	public class QBMovieClip extends SwfQuadBatch implements IMovieClip
	{
		public static const ANGLE_TO_RADIAN:Number = Math.PI / 180;
		
		private var _ownerSwf:Swf;
		private var _frames:Array;
		private var _labels:Array;
		private var _frameInfos:FrameChildData;
		private var _displayObjects:Object;
		private var _startFrame:int;
		private var _endFrame:int
		private var _currentFrame:int;
		private var _currentLabel:String;
		private var _isPlay:Boolean = false;
		private var _loop:Boolean = true;
		private var _autoUpdate:Boolean = false;
		private var _completeFunction:Function = null;
		private var _hasCompleteListener:Boolean;
		
		
		public function QBMovieClip(frames:Array,labels:Array,displayObjects:Object,ownerSwf:Swf):void
		{
			super();
			this._frames = frames;
			this._labels = labels;
			this._displayObjects = displayObjects;
			this._startFrame = 0;
			this._endFrame = frames.length;
			this._ownerSwf = ownerSwf;
			_currentFrame = 0;	
		}
		
		public function update():void
		{
			if(!_isPlay) return;
			_currentFrame += 1;
			if(_currentFrame > _endFrame)
			{
				if(_completeFunction) _completeFunction(this);
				if(_hasCompleteListener) dispatchEventWith(Event.COMPLETE);
				_currentFrame = _startFrame - 1;
				
				if(!_loop)
				{
					stop(false); 
					return;
				}
				
				if(_startFrame == _endFrame)
				{
					stop(false);
					return;
				}
			}
			else 
			{
				currentFrame = _currentFrame;
			}
		}
		
		public function set currentFrame(frame:int):void 
		{
			this.reset();
			_currentFrame = frame;
			_frameInfos = _frames[_currentFrame];
			
			var name:String;
			var type:String;
			var data:SpriteData;
			var display:DisplayObject;
			var useIndex:int;
			var i:int = 0;
			var len:int = _frameInfos.spriteChildsData.length;
			for(i; i != len; i++)
			{
				data = _frameInfos.spriteChildsData[i];
				useIndex = data.index;
				display = _displayObjects[data.childClassName][useIndex];
				
				display.x = data.x;
				display.y = data.y;
				display.scaleX = data.scaleX;
				display.scaleY = data.scaleY;
				display.skewX = data.sketwX * ANGLE_TO_RADIAN;
				display.skewY = data.sketwY * ANGLE_TO_RADIAN;
				display.name = data.childName;
				
				addChild(display);
			}
		}
		
		public function get currentFrame():int 
		{
			return _currentFrame;
		}
		
		public function stop(stopChild:Boolean = true):void 
		{
			_isPlay = false;
			_ownerSwf.swfUpdateManager.removeSwfMovieClip(this);
		}
		
		public function play():void
		{
			_isPlay = true;
			if(_autoUpdate) _ownerSwf.swfUpdateManager.addSwfMovieClip(this);
		}
		
		public function gotoAndStop(frame:Object,stopChild:Boolean = false):void
		{
			goTo(frame);
			stop(stopChild);
		}
		
		public function gotoAndPlay(frame:Object):void 
		{
			goTo(frame);
			play();
		}
		
		private function goTo(frame:*):void
		{
			if((frame is String))
			{
				var labelData:FrameLabelData = getLabel(frame);
				_currentLabel = labelData.name;
				_currentFrame = _startFrame = labelData.frame;
				_endFrame = labelData.endFrame;
			}
			else if(frame is int)
			{
				_currentFrame = _startFrame = frame;
				_endFrame = _frames.length - 1;
			}
			currentFrame = _currentFrame;
		}
		
		private function getLabel(label:String):FrameLabelData
		{
			var length:int = labels.length;
			var labelData:FrameLabelData;
			var i:int = 0;
			for(i; i != length; i++)
			{
				labelData = labels[i];
				if(labelData.name == label)
				{
					return labelData;
				}
			}
			return null;
		}
		
		public function get isPlay():Boolean
		{
			return _isPlay;
		}
		
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function set loop(val:Boolean):void
		{
			_loop = val;
		}
		
		public function set completeFunction(value:Function):void
		{
			_completeFunction = value;
		}
		
		public function get completeFunction():Function
		{
			return _completeFunction;
		}
		
		public function get totalFrames():int 
		{
			return _frames.length;
		}
		
		public function get currentLabel():String
		{
			return _currentLabel;
		}
		
		/**
		 * 获取所有标签
		 * */
		public function get labels():Array
		{
			var length:int = _labels.length;
			var returnLabels:Array = [];
			for (var i:int = 0; i < length; i++) 
			{
				returnLabels.push(_labels[i].name);
			}
			return returnLabels;
		}
		
		/**
		 * 是否包含某个标签
		 * */
		public function hasLabel(label:String):Boolean
		{
			var ls:Array = labels;
			var i:int = 0;
			var len:int = ls.length;
			for(i; i != len; i++)
			{
				if(ls[i].name == label)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 设置 / 获取 动画是否自动更新
		 * */
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}
		
		public function set autoUpdate(value:Boolean):void
		{
			_autoUpdate = value;
			if(_autoUpdate && _isPlay)
			{
				_ownerSwf.swfUpdateManager.addSwfMovieClip(this);
			}
			else if(!_autoUpdate && _isPlay)
			{
				_ownerSwf.swfUpdateManager.removeSwfMovieClip(this);
			}
		}
		
		public override function addEventListener(type:String, listener:Function):void
		{
			super.addEventListener(type,listener);
			_hasCompleteListener = hasEventListener(Event.COMPLETE);
		}
		
		public override function removeEventListener(type:String, listener:Function):void
		{
			super.removeEventListener(type,listener);
			_hasCompleteListener = hasEventListener(Event.COMPLETE);
		}
		
		public override function removeEventListeners(type:String=null):void
		{
			super.removeEventListeners(type);
			_hasCompleteListener = hasEventListener(Event.COMPLETE);
		}
		
		public override function dispose():void
		{
			_ownerSwf.swfUpdateManager.removeSwfMovieClip(this);
			_ownerSwf = null;
			super.dispose();
		}
		
	}
}