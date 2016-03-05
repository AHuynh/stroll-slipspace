package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Main menu and level select screen
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerMenu extends ABST_Container
	{
		private var engine:Engine;
		private var menu:SWC_MainMenu;
		
		/**
		 * A MovieClip handling the main menu
		 * @param	_eng			A reference to the Engine
		 */
		public function ContainerMenu(_eng:Engine)
		{
			engine = _eng;
			
			menu = new SWC_MainMenu();
			addChild(menu);
			menu.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void
		{
			menu.removeEventListener(Event.ADDED_TO_STAGE, init);
			menu.btn_start.addEventListener(MouseEvent.CLICK, onStart);
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
			if (menu != null)
			{
				menu.btn_start.removeEventListener(MouseEvent.CLICK, onStart);
				if (contains(menu))
					removeChild(menu);
			}
			menu = null;
			engine = null;
		}
	}
}
