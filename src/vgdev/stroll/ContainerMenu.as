package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import vgdev.stroll.managers.ManagerGeneric;
	import vgdev.stroll.props.consoles.ConsoleEmbark;
	import vgdev.stroll.props.Player;

	/**
	 * Main menu and level select screen
	 * Players walk around and interact with things instead of using a traditional menu
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerMenu extends ContainerGame
	{
		public var menu:SWC_MainMenu;
		
		/**
		 * A MovieClip handling the main menu
		 * @param	_eng			A reference to the Engine
		 */
		public function ContainerMenu(_eng:Engine)
		{
			super(_eng, true);
			engine = _eng;
			
			menu = new SWC_MainMenu();
			addChild(menu);
			menu.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		override protected function init(e:Event):void
		{
			menu.removeEventListener(Event.ADDED_TO_STAGE, init);
			menu.btn_start.addEventListener(MouseEvent.CLICK, onStart);
			
			gui = new SWC_GUI();
			engine.addChild(gui);
			gui.x += System.GAME_OFFSX;
			gui.y += System.GAME_OFFSY;
			hudConsoles = [gui.mod_p1, gui.mod_p2];
			
			shipHullMask = menu.mc_menu_hit;
			shipHullMask.visible = false;
			
			players = [new Player(this, menu.mc_player0, shipHullMask, 0, System.keyMap0),
					   new Player(this, menu.mc_player1, shipHullMask, 1, System.keyMap1)];
			
			consoles.push(new ConsoleEmbark(this, menu.mc_console_startL, players, menu.embarkReady));
			consoles.push(new ConsoleEmbark(this, menu.mc_console_startR, players, menu.embarkReady));
					   
			managerMap[System.M_PLAYER] = new ManagerGeneric(this);
			managerMap[System.M_PLAYER].setObjects(players);
			managers.push(managerMap[System.M_PLAYER]);

			managerMap[System.M_CONSOLE] = new ManagerGeneric(this);
			managerMap[System.M_CONSOLE].setObjects(consoles);
			managers.push(managerMap[System.M_CONSOLE]);
		}
		
		private function onStart(e:MouseEvent):void
		{
			completed = true;
			destroy(null);
		}
		
		override public function step():Boolean
		{
			for (var i:int = 0; i < managers.length; i++)
				managers[i].step();
			return completed;
		}
		
		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		override protected function destroy(e:Event):void
		{
			if (menu != null)
			{
				menu.btn_start.removeEventListener(MouseEvent.CLICK, onStart);
				if (contains(menu))
					removeChild(menu);
			}
			if (gui != null)
			{
				if (contains(gui))
					removeChild(gui);
			}
			gui = null;
			menu = null;
			engine = null;
		}
	}
}
