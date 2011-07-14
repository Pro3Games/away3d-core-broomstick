package away3d.materials
{
	import away3d.arcane;
	import away3d.events.LoaderEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.*;
	import flash.system.LoaderContext;

	use namespace arcane;
	
	/**
	 * Dispatched when the material completes a file load successfully.
	 * 
	 * @eventType away3d.events.ResourceEvent
	 */
	[Event(name="resourceComplete",type="away3d.events.LoaderEvent")]
	
	/**
	 * Dispatched when the material fails to load a file.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	[Event(name="loadError",type="away3d.events.LoaderEvent")]
	
	/**
	 * Dispatched every frame the material is loading.
	 * 
	 * @eventType flash.events.ProgressEvent
	 */
	[Event(name="progress",type="flash.events.ProgressEvent")]
	
	/**
	 * Bitmap material that loads it's texture from an external bitmapasset file.
	 */
	public class BitmapFileMaterial extends BitmapMaterial
	{
		private var _loader:Loader;
		private var _dispatcher:Sprite;
		private var _uri:String;
		
		/**
		 * Creates a new <code>BitmapFileMaterial</code> object.
		 *
		 * @param	url					The location of the bitmapasset to load.
		 */
		public function BitmapFileMaterial( url :String = "", checkPolicy:Boolean = false)
		{
			super(new BitmapData(64,64, false, 0xFFFFFF));
			
			url = (url.substring(0,7) == "/file:/")? url.substring(7,url.length) : url;
			
			if(url.substring(0,2) == "//"){
				url = url.toLowerCase();
				var charvar:int = 97;
				while(charvar<123){
					if(url.charCodeAt(2) == charvar){
						url = (url.substring(0,5) == "//"+String.fromCharCode(charvar)+":/")? url.substring(2,url.length) : url;
						break;
					}
					charvar++; 
				}
			}
			
			if(url.charCodeAt(url.length-1) < 49)
				url = url.substring(0, url.length-1);
			
			_dispatcher = new Sprite();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = checkPolicy;
			_uri = unescape(url);
			_loader.load(new URLRequest(_uri), context);
		}
		
		/**
		 * @return	the loader used for this material
		 */
		public function get loader():Loader
		{
			return _loader;
		}
		
		private function onError(e:IOErrorEvent):void
		{
			if(_dispatcher.hasEventListener(LoaderEvent.LOAD_ERROR))
				_dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_ERROR, _uri, e.text ));
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			if(_dispatcher.hasEventListener(ProgressEvent.PROGRESS))
				_dispatcher.dispatchEvent(e);
		}
		
		private function onComplete(e:Event):void
		{
			bitmapData = Bitmap(_loader.content).bitmapData;
			
			if(_dispatcher.hasEventListener(LoaderEvent.RESOURCE_COMPLETE))
				_dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.RESOURCE_COMPLETE, _uri));
		}
	}
}

