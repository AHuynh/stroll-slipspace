package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * Main menu and level select screen
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerMenu extends ABST_Container
	{
		private var engine:Engine;
		private var menu:SWC_MainMenu;
		private var checkStory:Boolean = false;
		
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
			menu.play();
			menu.btn_start.removeEventListener(MouseEvent.CLICK, onStart);
			menu.mc_story.setActionKeys(Keyboard.F, Keyboard.PERIOD);
			checkStory = true;
			
			//completed = true;		// DEBUGGING SHORTCUT -- REMOVE LATER
		}
		
		override public function step():Boolean 
		{
			if (!checkStory) return completed;
			if (menu.mc_story.currentFrame == menu.mc_story.totalFrames)
			{
				checkStory = false;
				engine.shipColor = menu.mc_story.cp_colorpicker.selectedColor;
				destroy();
				completed = true;
			}
			return completed;
		}
		
		/**
		 * Called by Story once it's done
		 * @param	col		The color to tint the slipship
		 */
		public function isDone(col:uint):void
		{
			destroy();
			completed = true;
		}
		
		/**
		 * Clean-up code
		 */
		protected function destroy():void
		{
			if (menu != null)
			{
				if (contains(menu))
					removeChild(menu);
			}
			menu = null;
			engine = null;
		}
	}
}
