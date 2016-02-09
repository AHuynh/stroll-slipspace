package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	/**
	 * Main menu and level select screen
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerMenu extends ABST_Container
	{
		public var eng:Engine;					// a reference to the Engine
		public var swc:SWC_MainMenu;			// the actual MovieClip
		
		/**
		 * A MovieClip handling the main menu
		 * @param	_eng			A reference to the Engine
		 */
		public function ContainerMenu(_eng:Engine)
		{			
			super();
			eng = _eng;
			
			swc = new SWC_MainMenu();
			addChild(swc);
			
			swc.btn_start.addEventListener(MouseEvent.CLICK, onStart);
		}
		
		private function onStart(e:MouseEvent):void
		{
			completed = true;
			destroy(null);
		}
		
		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		protected function destroy(e:Event):void
		{
			if (swc != null)
			{
				swc.btn_start.removeEventListener(MouseEvent.CLICK, onStart);
				if (contains(swc))
					removeChild(swc);
			}
			swc = null;
			eng = null;
		}
	}
}
