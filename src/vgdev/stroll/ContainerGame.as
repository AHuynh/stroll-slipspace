package vgdev.stroll
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import vgdev.stroll.managers.ABST_Manager;
	import vgdev.stroll.managers.ManagerEProjectile;
	import vgdev.stroll.managers.ManagerGeneric;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleTurret;
	import vgdev.stroll.props.Player;
	
	/**
	 * Primary game container and controller
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{		
		public var engine:Engine;		// the game's Engine
		public var game:SWC_Game;		// the Game SWC, containing all the base assets

		public var players:Array;
		private var keyMap0:Object = { "RIGHT":Keyboard.RIGHT,	"UP":Keyboard.UP,
									   "LEFT":Keyboard.LEFT,	"DOWN":Keyboard.DOWN,
									   "ACTION":Keyboard.COMMA, "CANCEL":Keyboard.PERIOD };
		private var keyMap1:Object = { "RIGHT":Keyboard.D,		"UP":Keyboard.W,
									   "LEFT":Keyboard.A,		"DOWN":Keyboard.S,
									   "ACTION":Keyboard.Z, 	"CANCEL":Keyboard.X };
									   
		public var consoles:Array;
		
		public var managers:Array = [];
		private var manPlayer:ABST_Manager;
		private var manConsole:ABST_Manager;
		
		/**
		 * A MovieClip containing all of a Stroll level
		 * @param	eng			A reference to the Engine
		 */
		public function ContainerGame(eng:Engine)
		{
			super();
			engine = eng;
			
			game = new SWC_Game();
			addChild(game);
			
			game.mc_bg.gotoAndStop("space");
			//engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			game.mc_ship.mc_ship_hit.visible = false;
			game.mc_ship.mod_nav.visible = false;
			game.mc_ship.mod_shield.visible = false;
			
			
			players = [new Player(this, game.mc_ship.mc_player0, game.mc_ship.mc_ship_hit, 0, keyMap0),
					   new Player(this, game.mc_ship.mc_player1, game.mc_ship.mc_ship_hit, 1, keyMap1)];
					   
			consoles = [];			
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console00, game.mc_ship.turret_0,		// front
											players, [-120, 120], [1, -1, 3, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console02, game.mc_ship.turret_1,		// left
											players, [-165, 15], [2, -1, 0, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console04, game.mc_ship.turret_2,		// right
											players, [-15, 165], [0, -1, 2, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console05, game.mc_ship.turret_4,		// rear
											players, [-90, 90], [3, -1, 1, -1]));
			
			// TODO dynamic camera
			//game.scaleX = game.scaleY = .7;
			
			managers.push(new ManagerEProjectile(this));
			
			manPlayer = new ManagerGeneric(this)
			manPlayer.setObjects(players);
			managers.push(manPlayer);
			
			manConsole = new ManagerGeneric(this)
			manConsole.setObjects(consoles);
			managers.push(manConsole);
		}

		/**
		 * Callback when a key is pressed; i.e. a key goes from NOT PRESSED to PRESSED
		 * @param	e		the associated KeyboardEvent; use e.keyCode
		 */
		private function downKeyboard(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
			}
		}
		
		public function onAction(p:Player):void
		{
			for (var i:int = 0; i < consoles.length; i++)
				consoles[i].onAction(p);
		}
		
		/**
		 * Called by Engine every frame to update the game
		 * @return		completed, true if this container is done
		 */
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
		protected function destroy(e:Event):void
		{			
			if (engine.stage.hasEventListener(KeyboardEvent.KEY_DOWN))
				engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			if (game != null && contains(game))
				removeChild(game);
			game = null;

			engine = null;
		}
	}
}
