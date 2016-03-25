package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.ui.Keyboard;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import vgdev.stroll.props.*;
	import vgdev.stroll.props.consoles.*;
	import vgdev.stroll.props.enemies.*;
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
		public var gui:SWC_GUI;
		public var engine:Engine;

		public var level:Level;
		public var ship:Ship;
		public var camera:Cam;
		public var tails:TAILS;
		public var background:Background;
		public var alerts:Alerts;
		public var bossBar:BossBar;
		
		/// Whether or not the game is paused
		public var isPaused:Boolean = false;		// from P
		public var isTailsPaused:Boolean = false;	// from TAILS
		
		/// UI consoles; an Array of MovieClips
		public var hudConsoles:Array;
		public var hudTitles:Array;
		public var hudBars:Array;
		public var painIndicators:Array;
		
		/// The current ship's hitbox, either hull or shields
		public var shipHitMask:MovieClip;			// active external ship hitmask; can be hull or shield
		public var shipHullMask:MovieClip;			// external ship hitmask; always hull
		public var shipInsideMask:MovieClip;		// internal ship hitmask; always hull
		
		/// Array of Player objects
		public var players:Array = [];
			   
		/// Array of ABST_Consoles and ABST_Items, used to help figure out which console a player is trying to interact with
		public var consoles:Array = [];
		
		public var managers:Array = [];
		public var managerMap:Object = new Object();
		
		// TEMPORARY
		private const TAILS_DEFAULT:String = "Hi! I'm TAILS; the ship AI.\n\n" +
											 "I've booted up the ship's basic systems. Check them out before we jump.\n\n" +
											 "OK, are both of you ready?";
		
		/**
		 * A MovieClip containing all of a Stroll level
		 * @param	eng			A reference to the Engine
		 */
		public function ContainerGame(eng:Engine)
		{
			super();
			engine = eng

			game = new SWC_Game();
			addChild(game);
			game.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void
		{
			game.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//game.mc_bg.gotoAndStop("space");
			
			// init the GUI
			gui = new SWC_GUI();	
			engine.superContainer.mc_container.addChild(gui);
			gui.mc_pause.visible = false;
			gui.mc_tails.visible = false;
			hudConsoles = [gui.mod_p1, gui.mod_p2];
			gui.tf_titleL.visible = false;
			gui.tf_titleR.visible = false;
			hudTitles = [gui.tf_titleL, gui.tf_titleR];
			hudBars = [gui.bar_crew1, gui.bar_crew2];
			painIndicators = [gui.mc_painL, gui.mc_painR];
			gui.tf_distance.text = "Supr Jmp";
			
			// init support classes
			level = new Level(this);
			tails = new TAILS(this, gui.mc_tails);
			ship = new Ship(this);
			background = new Background(this, game.mc_bg);
			background.setStyle("homeworld");
			camera = new Cam(this, gui);
			camera.step();
			alerts = new Alerts(this, gui.mc_alerts);	
			bossBar = new BossBar(this, gui.mc_bossbar);
			
			// set up the hitmasks
			shipHullMask = game.mc_ship.mc_ship_hit;
			shipHullMask.visible = false;
			shipInsideMask = game.mc_ship.mc_ship_hithard;
			shipInsideMask.visible = false;
			setHitMask(false);

			// link the game's assets
			players = [new Player(this, game.mc_ship.mc_player0, shipInsideMask, 0, System.keyMap0),
					   new Player(this, game.mc_ship.mc_player1, shipInsideMask, 1, System.keyMap1)];

			// placeholder ship
			/*consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console00, game.mc_ship.turret_0,		// front
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
			consoles.push(new ConsoleSlipdrive(this, game.mc_ship.mc_console_slip, players));*/
			
			// Eagle
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretf, game.mc_ship.turret_f,		// front
											players, [-120, 120], [1, 2, 0, 3], 0));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretl, game.mc_ship.turret_l,		// left
											players, [-165, 10], [1, 2, 0, 3], 1));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretr, game.mc_ship.turret_r,		// right
											players, [-10, 165], [1, 2, 0, 3], 2));
			consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretb, game.mc_ship.turret_b,		// rear
											players, [-65, 65], [1, 2, 0, 3], 3));
			consoles[3].rotOff = 180;
			consoles.push(new ConsoleShieldRe(this, game.mc_ship.mc_console_shieldre, players));
			consoles.push(new ConsoleNavigation(this, game.mc_ship.mc_console_navigation, players));
			consoles.push(new ConsoleSlipdrive(this, game.mc_ship.mc_console_slipdrive, players));
			consoles.push(new ConsoleShields(this, game.mc_ship.mc_console_shield, players, false));
			consoles.push(new ConsoleSensors(this, game.mc_ship.mc_console_sensors, players, false));
			
			consoles.push(new Omnitool(this, game.mc_ship.item_fe_0, players, false));
			consoles.push(new Omnitool(this, game.mc_ship.item_fe_1, players, false));
			
			var i:int;
			
			// init the managers			
			managerMap[System.M_EPROJECTILE] = new ManagerProjectile(this);
			managers.push(managerMap[System.M_EPROJECTILE]);
			
			managerMap[System.M_IPROJECTILE] = new ManagerProjectile(this);
			managers.push(managerMap[System.M_IPROJECTILE]);

			managerMap[System.M_PLAYER] = new ManagerGeneric(this);
			managerMap[System.M_PLAYER].setObjects(players);
			managers.push(managerMap[System.M_PLAYER]);
			
			managerMap[System.M_CONSOLE] = new ManagerGeneric(this);
			managerMap[System.M_CONSOLE].setObjects(consoles);
			managers.push(managerMap[System.M_CONSOLE]);
			
			managerMap[System.M_DECOR] = new ManagerGeneric(this);
			managers.push(managerMap[System.M_DECOR]);
			
			managerMap[System.M_FIRE] = new ManagerGeneric(this);
			managers.push(managerMap[System.M_FIRE]);
			
			managerMap[System.M_ENEMY] = new ManagerEnemy(this);
			managers.push(managerMap[System.M_ENEMY]);
			
			managerMap[System.M_DEPTH] = new ManagerDepth(this);
			managers.push(managerMap[System.M_DEPTH]);
			for (i = 0; i < players.length; i++)
				managerMap[System.M_DEPTH].addObject(players[i]);
			for (i = 0; i < consoles.length; i++)
				managerMap[System.M_DEPTH].addObject(consoles[i]);
				
			managerMap[System.M_PROXIMITY] = new ManagerProximity(this);
			// -- (should not push this to managers, as it does not need to be stepped)
			for (i = 0; i < players.length; i++)
				players[i].manProx = managerMap[System.M_PROXIMITY];
			for (i = 0; i < consoles.length; i++)
				managerMap[System.M_PROXIMITY].addObject(consoles[i]);
			
			SoundManager.playBGM("bgm_calm", .4);
						
			engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			tails.show(TAILS_DEFAULT);
			tails.showNew = true;
			camera.setCameraFocus(new Point(0, -100));
			//camera.setCameraFocus(new Point(0, -20));
		}
		
		/**
		 * Add the given Object to the game
		 * @param	mc				The ABST_Object to add
		 * @param	manager			The ID of the manager that will manage mc
		 * @param	manageDepth		If true, object's depth will be updated based on its y position
		 * @return					The ABST_Object that was created
		 */
		public function addToGame(obj:ABST_Object, manager:int):ABST_Object
		{
			switch (manager)
			{
				case System.M_CONSOLE:
				case System.M_DEPTH:
				case System.M_FIRE:
					game.mc_ship.addChild(obj.mc_object);
					managerMap[System.M_DEPTH].addObject(obj);
				break;
				default:
					game.mc_exterior.addChild(obj.mc_object);
			}
			managerMap[manager].addObject(obj);
			return obj;
		}
		
		/**
		 * Add a decoration object to the game
		 * @param	style			The label the SWC_Decor should use
		 * @param	params			Object map with additional attributes
		 * @return					The ABST_Object that was created
		 */
		public function addDecor(style:String, params:Object = null):ABST_Object
		{
			return addToGame(new Decor(this, new SWC_Decor(), style, params), System.M_DECOR);
		}

		/**
		 * Callback when a key is pressed; i.e. a key goes from NOT PRESSED to PRESSED
		 * @param	e		the associated KeyboardEvent; use e.keyCode
		 */
		private function downKeyboard(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
				case Keyboard.P:
					isPaused = !isPaused;
					/*if (isTruePaused())					// halt or resume background animation
						game.mc_bg.base.stop();
					else
						game.mc_bg.base.play();*/
					gui.mc_pause.visible = isPaused;
				break;
				case Keyboard.J:		// TODO remove temporary testing
					jump();
				break;
				case Keyboard.K:
					players[System.getRandInt(0, 1)].changeHP( -9999);
				break;
				/*case Keyboard.K:
					managerMap[System.M_ENEMY].killAll();
				break;*/
				/*case Keyboard.K:
					addFires(1);
				break;*/
			}
		}
		
		/**
		 * Evaluates all possible reasons for being paused and returns if the game is actually paused
		 * @return		true if the game is paused for any reason
		 */
		public function isTruePaused():Boolean
		{
			return isPaused || isTailsPaused;
		}
		
		/**
		 * Callback when a player not at a console performs their 'USE' action
		 * If TAILS is up, acknowledge.
		 * Otherwise, attempts to activate (set the player to be using) the appropriate console
		 * @param	p		the Player that is trying to USE something
		 */
		public function onAction(p:Player):void
		{
			if (tails.isActive())
			{
				if (tails.acknowledge(p.playerID))
					isTailsPaused = false;
			}
			else
			{
				for (var i:int = 0; i < consoles.length; i++)
					consoles[i].onAction(p);
			}
		}
		
		/**
		 * Called by Engine every frame to update the game
		 * @return		completed, true if this container is done
		 */
		override public function step():Boolean
		{			
			if (completed)
				return completed;
				
			if (!isPaused)
				tails.step();
				
			if (isTruePaused())
				return completed;

			level.step();
			ship.step();
			camera.step();
			alerts.step();
			background.step(atHomeworld() ? 0 : ship.slipSpeed * 150);
			bossBar.step();
			
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
		 * Called by Ship when jumping to the next sector
		 */
		public function jump():void
		{
			playJumpEffect();
			
			// automatically reset the camera to the center for Sector 0 only
			if (level.sectorIndex == 0)
				camera.setCameraFocus(new Point(0, 20));
	
			// game finished state
			if (level.nextSector())
			{
				destroy(null);
				completed = true;
			}
			else
			{
				var boss:Boolean = level.sectorIndex % 4 == 0;
				
				if (boss)
					SoundManager.playBGM("bgm_boss", System.VOL_BGM);
				else if (level.sectorIndex % 4 == 1)
					SoundManager.playBGM("bgm_calm", System.VOL_BGM);
					
				if (level.sectorIndex == 9)
					boss = true;
					
				tails.show(level.getTAILS(), boss ? 0 : 120, (level.sectorIndex > 8 ? "HEADS" : null));
				
				// hide all "New!" and console tutorial messages
				for each (var console:ABST_Console in consoles)
					console.showNew( -1);
				gui.mod_p1.mc_tutorial.visible = false;
				gui.mod_p2.mc_tutorial.visible = false;
				
				gui.mc_left.visible = false;
				gui.mc_right.visible = false;
				
				tails.tutorialMode = level.sectorIndex % 4 == 0;
				tails.tutorialMode = false;
			}
		}
		
		/**
		 * Play the effect for jumping and remove all external objects (but don't actually jump)
		 */
		public function playJumpEffect():void
		{
			SoundManager.playSFX("sfx_slipjump");
			game.mc_jump.gotoAndPlay(2);		// play the jump animation
				
			// remove all external-ship instances
			managerMap[System.M_EPROJECTILE].killAll();
			managerMap[System.M_ENEMY].killAll();
			managerMap[System.M_DECOR].killAll();
		}
		
		/**
		 * Set the color tint of modules
		 * @param	col		uint of the module color
		 */
		public function setModuleColor(col:uint):void
		{
			var ct:ColorTransform = new ColorTransform();
			if (col != System.COL_WHITE)
				ct.color = col;
			
			gui.tf_titleL.transform.colorTransform = ct;
			gui.tf_titleR.transform.colorTransform = ct;
			hudBars[0].transform.colorTransform = ct;
			hudBars[1].transform.colorTransform = ct;
			hudConsoles[0].transform.colorTransform = ct;
			hudConsoles[1].transform.colorTransform = ct;
		}
		
		/**
		 * Check if at the first or last (non-hostile) sectors
		 * @return
		 */
		public function atHomeworld():Boolean
		{
			return level.sectorIndex % 13 == 0;
		}

		/**
		 * Add num fires to random valid positions in the ship
		 * @param	num		number of fires to ignite
		 */
		public function addFires(num:int):void
		{
			var pos:Point;
			for (var i:int = 0; i < num; i++)
			{
				pos = getRandomShipLocation();
				if (pos == null) continue;
				addToGame(new InternalFire(this, new SWC_Decor(), pos, shipInsideMask), System.M_FIRE);
			}
		}
		
		/**
		 * Add fire to the given position in the ship
		 * @param	loc		location of fire
		 */
		public function addFireAt(loc:Point):void
		{
			addToGame(new InternalFire(this, new SWC_Decor(), loc, shipInsideMask), System.M_FIRE);
		}
		
		/**
		 * Create sparks randomly in the ship
		 * @param	num		number of sparks
		 */
		public function addSparks(num:int):void
		{
			var pos:Point;
			for (var i:int = 0; i < num; i++)
			{
				pos = getRandomShipLocation();
				if (pos == null) continue;
				addDecor("electricSparks", {
						"x": pos.x,
						"y": pos.y,
						"dr": System.getRandNum( -40, 40),
						"rot": System.getRandNum(0, 360),
						"scale": System.getRandNum(.7, 1.5)
				});
			}
		}
		
		/**
		 * Create sparks at the give position, with some vary
		 * @param	num		number of sparks
		 * @param	loc		location of sparks
		 */
		public function addSparksAt(num:int, loc:Point):void
		{
			var pos:Point;
			for (var i:int = 0; i < num; i++)
			{
				pos = new Point(loc.x + System.getRandNum( -5, 5), loc.y + System.getRandNum( -5, 5));
				addDecor("electricSparks", {
						"x": pos.x,
						"y": pos.y,
						"dr": System.getRandNum( -40, 40),
						"rot": System.getRandNum(0, 360),
						"scale": System.getRandNum(.7, 1.5)
				});
			}
		}
		
		/**
		 * Get a random valid point in the ship
		 * @return		random point in the ship, or null if one wasn't found
		 */
		public function getRandomShipLocation():Point
		{
			var pos:Point;
			var tries:int = 25;		// give up after trying too many times
			do
			{
				pos = new Point(System.getRandNum(-shipInsideMask.width, shipInsideMask.width) * .4  + System.GAME_OFFSX,
								System.getRandNum( -shipInsideMask.height, shipInsideMask.height) * .4  + System.GAME_OFFSY);
			} while (shipInsideMask.hitTestPoint(pos.x, pos.y, true) && tries-- > 0);
			pos.x -= System.GAME_OFFSX;
			pos.y -= System.GAME_OFFSY;
			return tries == 0 ? null : pos;
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
