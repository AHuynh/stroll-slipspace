package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.ui.Keyboard;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import vgdev.stroll.props.*;
	import vgdev.stroll.props.consoles.*;
	import vgdev.stroll.support.*;
	import vgdev.stroll.managers.*;
	
	/**
	 * Primary game container and controller
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{		
		/// The SWC object containing graphics assets for the game
		public var game:SWC_Game;
		public var engine:Engine;

		public var level:Level;
		public var gui:SWC_GUI;
		
		public var hudConsoles:Array;
		
		public var ship:Ship;
		public var camera:Cam;
		
		/// The current ship's hitbox, either hull or shields
		public var shipHitMask:MovieClip;
		public var shipHullMask:MovieClip;
		
		public var players:Array = [];
			   
		/// Array of ABST_Consoles, used to help figure out which console a player is trying to interact with
		public var consoles:Array = [];
		
		public var managers:Array = [];
		public var managerMap:Object = new Object();
		
		/**
		 * A MovieClip containing all of a Stroll level
		 * @param	eng			A reference to the Engine
		 */
		public function ContainerGame(eng:Engine, isMenu:Boolean = false)
		{
			super();
			engine = eng
			
			if (!isMenu)
			{
				game = new SWC_Game();
				addChild(game);
				game.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		protected function init(e:Event):void
		{
			game.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			gui = new SWC_GUI();
			engine.addChild(gui);
			gui.x += System.GAME_OFFSX;
			gui.y += System.GAME_OFFSY;
			hudConsoles = [gui.mod_p1, gui.mod_p2];
			
			level = new Level(this);
			
			game.mc_bg.gotoAndStop("space");
			
			shipHullMask = game.mc_ship.mc_ship_hit;
			shipHullMask.visible = false;
			setHitMask(false);

			// link the game's assets
			players = [new Player(this, game.mc_ship.mc_player0, shipHullMask, 0, System.keyMap0),
					   new Player(this, game.mc_ship.mc_player1, shipHullMask, 1, System.keyMap1)];

			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console00, game.mc_ship.turret_0,		// front
											players, [-120, 120], [1, -1, 3, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console02, game.mc_ship.turret_1,		// left
											players, [-165, 15], [2, -1, 0, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console04, game.mc_ship.turret_2,		// right
											players, [-15, 165], [0, -1, 2, -1]));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console05, game.mc_ship.turret_4,		// rear
											players, [-90, 90], [3, -1, 1, -1]));
			consoles[3].rotOff = 180;
			consoles.push(new ConsoleShields(this, game.mc_ship.mc_console03, players));
			consoles.push(new ConsoleSensors(this, game.mc_ship.mc_console06, players));
			consoles.push(new ConsoleSlipdrive(this, game.mc_ship.mc_console_slip, players));
			
			ship = new Ship(this);
			camera = new Cam(this);
			
			// init the managers
			managerMap[System.M_EPROJECTILE] = new ManagerEProjectile(this);
			managers.push(managerMap[System.M_EPROJECTILE]);

			managerMap[System.M_PLAYER] = new ManagerGeneric(this);
			managerMap[System.M_PLAYER].setObjects(players);
			managers.push(managerMap[System.M_PLAYER]);

			managerMap[System.M_CONSOLE] = new ManagerGeneric(this);
			managerMap[System.M_CONSOLE].setObjects(consoles);
			managers.push(managerMap[System.M_CONSOLE]);
			
			managerMap[System.M_ENEMY] = new ManagerGeneric(this);
			/*addToGame(new ABST_Enemy(this, new SWC_Enemy(), new Point(200, 200)), System.M_ENEMY);
			addToGame(new ABST_Enemy(this, new SWC_Enemy(), new Point(160, 210)), System.M_ENEMY);
			addToGame(new ABST_Enemy(this, new SWC_Enemy(), new Point(180, 190)), System.M_ENEMY);*/
			managers.push(managerMap[System.M_ENEMY]);
			
			//SoundManager.playBGM("bgm_battle1");
						
			engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
		}
		
		/**
		 * Add the given Object to the game
		 * @param	mc			The ABST_Object to add
		 * @param	manager		The ID of the manager that will manage mc
		 */
		public function addToGame(obj:ABST_Object, manager:int):void
		{
			game.addChild(obj.mc_object);
			managerMap[manager].addObject(obj);
		}

		/**
		 * Callback when a key is pressed; i.e. a key goes from NOT PRESSED to PRESSED
		 * @param	e		the associated KeyboardEvent; use e.keyCode
		 */
		private function downKeyboard(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
				/*case Keyboard.O:
					camera.setCameraScale(2);
				break;
				case Keyboard.P:
					camera.setCameraScale(1);
				break;*/
			}
		}
		
		/**
		 * Callback when a player not at a console performs their 'USE' action
		 * @param	p		the Player that is trying to USE something
		 */
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
			if (completed)
				return true;

			level.step();
			ship.step();
			camera.step();
			
			for (var i:int = 0; i < managers.length; i++)
				managers[i].step();
			return completed;
		}
		
		/**
		 * Set the ship's exterior hit mask to either the hull or the shield
		 * @param	isHull	true if using hull, false if using shields
		 */
		public function setHitMask(isHull:Boolean):void
		{
			shipHitMask = isHull ? shipHullMask : game.mc_ship.shield;
		}
		
		/**
		 * Called by ship when jumping to the next sector
		 */
		public function jump():void
		{
			game.mc_jump.gotoAndPlay(2);		// play the jump animation
			gui.mc_jumpReady.visible = false;
				
			// remove all external-ship instances
			managerMap[System.M_EPROJECTILE].killAll();
			managerMap[System.M_ENEMY].killAll();
			
			if (level.nextWave())
			{
				destroy(null);
				completed = true;
			}
		}

		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		protected function destroy(e:Event):void
		{
			if (engine.stage.hasEventListener(KeyboardEvent.KEY_DOWN))
				engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			for (var i:int = 0; i < managers.length; i++)
			{
				managers[i].destroy();
				managers[i] = null;
			}
			managers = null;
				
			if (game != null && contains(game))
				removeChild(game);
			game = null;

			engine = null;
		}
	}
}
