package vgdev.stroll
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.text.TextField;
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
	import vgdev.stroll.support.graph.GraphMaster;
	import vgdev.stroll.support.graph.GraphNode;
	
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

		private var supportClasses:Array = [];
		public var level:Level;
		public var ship:Ship;
		public var camera:Cam;
		public var tails:TAILS;
		public var graph:GraphMaster;
		public var background:Background;
		public var alerts:Alerts;
		public var bossBar:BossBar;
		public var visualEffects:VisualEffects;
		
		/// Whether or not the game is paused
		public var isPaused:Boolean = false;			// from P
		public var isTailsPaused:Boolean = false;		// from TAILS
		public var isDefeatedPaused:Boolean = false;	// ship is exploding
		public var isGameOver:Boolean = false;			// game over screen
		public var isAllIncap:Boolean = false;
		
		public var serious:Boolean = false;				// prevent reacting to high-fives
		
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
		
		private const TAILS_DEFAULT:String = "Hi! I'm TAILS; the ship AI.\n\n" +
											 "I've booted up the ship's basic systems. Check them out before we jump.\n\n" +
											 "OK, are both of you ready?";
		private const TAILS_RELOAD:String = "Huh? What just happened?\n\n" +
											 "Not really sure, to be honest. Almost like we...\n\n" +
											 "Uh, anyway, how about we keep going?";
		private const HEADS_RELOAD:String = "Error. System clock anomaly.\n" +
											 "Previous state detected.\n\n" +
											 "Disregard. Continue mission. Y/N?";
											 
		// pause menu helpers
		private var escDown:Boolean = false;
		private var resetCounter:int = 0;
		private var justPaused:Boolean = false;
		public var useAutoCam:Boolean = true;
		
		public var gameOverAnnouncer:String = "TAILS";
		private var useSave:Boolean = false;
		
		public var shipName:String = "Eagle";
		
		/**
		 * A MovieClip containing all of a Stroll level
		 * @param	eng			A reference to the Engine
		 */
		public function ContainerGame(eng:Engine, _shipName:String, _useSave:Boolean = false )
		{
			super();
			engine = eng;
			shipName = _shipName;
			//shipName = "Kingfisher";
			useSave = _useSave;
			
			// reset all static classes
			EnemyPeepsEye.numEyes = 0;
			ABST_Console.numCorrupted = 0;
			ABST_Console.beingUsed = false;
			ConsoleFAILS.difficulty = 0;
			ConsoleFAILS.puzzleActive = false;
			EnemyCrystal.numCrystals = 0;
			EnemyCrystal.totalNumCorrupted = 0;
			
			game = new SWC_Game();
			addChild(game);
			game.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void
		{
			game.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// init the GUI
			gui = new SWC_GUI();	
			engine.superContainer.mc_container.addChild(gui);
			gui.mc_pause.visible = false;
			gui.mc_pause.tf_reset.visible = false;
			gui.mc_pause.btn_camera.addEventListener(MouseEvent.CLICK, onAutoCam);
			gui.mc_lose.visible = false;
			gui.mc_lose.tf_reset.visible = false;
			gui.mc_win.visible = false;
			gui.mc_tails.visible = false;
			hudConsoles = [gui.mod_p1, gui.mod_p2];
			hudConsoles[0].mc_taunt.visible = false;
			hudConsoles[1].mc_taunt.visible = false;
			gui.tf_titleL.visible = false;
			gui.tf_titleR.visible = false;
			hudTitles = [gui.tf_titleL, gui.tf_titleR];
			hudBars = [gui.bar_crew1, gui.bar_crew2];
			painIndicators = [gui.mc_painL, gui.mc_painR];
			gui.tf_distance.text = "Supr Jmp";

			game.mc_ship.gotoAndStop(shipName.toLowerCase());
			
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
			visualEffects = new VisualEffects(this);
			graph = new GraphMaster(this);
			
			supportClasses = [level, ship, camera, alerts, bossBar, visualEffects, graph];
			
			// set up the hitmasks
			shipHullMask = game.mc_ship.mc_ship_hit;
			shipHullMask.visible = false;
			shipInsideMask = game.mc_ship.mc_ship_hithard;
			shipInsideMask.visible = false;
			setHitMask(false);
			
			game.mc_wingman0.visible = false;
			game.mc_wingman1.visible = false;
			
			var i:int;
			players = [null, null];
			for (i = 0; i < 2; i++)
			{
				if (engine.wingman[i])
				{
					if (i == 0)
						players[i] = new WINGMAN(this, game.mc_ship.mc_player0, shipInsideMask, 0, System.keyMap0, gui.mc_wingmanL, game.mc_wingman0)
					else
						players[i] = new WINGMAN(this, game.mc_ship.mc_player1, shipInsideMask, 1, System.keyMap1, gui.mc_wingmanR, game.mc_wingman1)
				}
				else
				{
					if (i == 0)
					{
						players[i] = new Player(this, game.mc_ship.mc_player0, shipInsideMask, 0, System.keyMap0);
						gui.mc_wingmanL.visible = false;
					}
					else
					{
						players[i] = new Player(this, game.mc_ship.mc_player1, shipInsideMask, 1, System.keyMap1);
						gui.mc_wingmanR.visible = false;
					}
				}
			}
			
			
			// DEBUGGING TOOL -- set to true for release, false to debug
			var useLocks:Boolean = true;
					   
			// --- Eagle --------------------------------------------------------------------------------------------------------
			if (shipName == "Eagle")
			{
				consoles.push(new Omnitool(this, game.mc_ship.item_fe_0, players, useLocks));		// give priority to Omnitools by listing them first
				consoles.push(new Omnitool(this, game.mc_ship.item_fe_1, players, useLocks));
				
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretf, game.mc_ship.turret_f,		// front
												players, [-120, 120], [1, 2, 0, 3], 0));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretl, game.mc_ship.turret_l,		// left
												players, [-165, 10], [1, 2, 0, 3], 1));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretr, game.mc_ship.turret_r,		// right
												players, [-10, 165], [1, 2, 0, 3], 2));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretb, game.mc_ship.turret_b,		// rear
												players, [-65, 65], [1, 2, 0, 3], 3));
				consoles[5].rotOff = 180;
				consoles.push(new ConsoleShieldRe(this, game.mc_ship.mc_console_shieldre, players));
				consoles.push(new ConsoleNavigation(this, game.mc_ship.mc_console_navigation, players));
				consoles.push(new ConsoleSlipdrive(this, game.mc_ship.mc_console_slipdrive, players));
				consoles.push(new ConsoleShields(this, game.mc_ship.mc_console_shield, players, useLocks));
				consoles.push(new ConsoleSensors(this, game.mc_ship.mc_console_sensors, players, useLocks));
			}
			// --- Eagle --------------------------------------------------------------------------------------------------------
			// --- Kingfisher ---------------------------------------------------------------------------------------------------
			else if (shipName == "Kingfisher")
			{
				consoles.push(new Omnitool(this, game.mc_ship.item_fe_0, players, useLocks));		// give priority to Omnitools by listing them first
				consoles.push(new Omnitool(this, game.mc_ship.item_fe_1, players, useLocks));
				
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretl, game.mc_ship.turret_lf,		// left front
												players, [-120, 15], [1, 2, 0, 3], 1));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretbl, game.mc_ship.turret_lr,		// left rear
												players, [-5, 130], [1, 2, 0, 3], 3));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretf, game.mc_ship.turret_rf,		// right front
												players, [-25, 130], [1, 2, 0, 3], 0));
				consoles.push(new ConsoleTurretAoE(this, game.mc_ship.mc_console_turretr, game.mc_ship.turret_r,	// right
												players, [-180, 180], [1, 2, 0, 3], 4, true));
				consoles.push(new ConsoleTurret(this, game.mc_ship.mc_console_turretbr, game.mc_ship.turret_rr,		// right rear
												players, [-135, 45], [1, 2, 0, 3], 2, true));
				consoles[3].rotOff = 180;
				consoles[6].rotOff = 180;
				consoles.push(new ConsoleShieldRe(this, game.mc_ship.mc_console_shieldre, players));
				consoles.push(new ConsoleNavigation(this, game.mc_ship.mc_console_navigation, players));
				consoles.push(new ConsoleSlipdrive(this, game.mc_ship.mc_console_slipdrive, players));
				consoles.push(new ConsoleShields(this, game.mc_ship.mc_console_shield, players, useLocks));
				consoles.push(new ConsoleSensors(this, game.mc_ship.mc_console_sensors, players, useLocks));
			}
			// --- Kingfisher ---------------------------------------------------------------------------------------------------
			graph.initShip(shipName);
			game.mc_ship.mc_shipBase.tintShip(engine.shipColor);
			
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
			
			managerMap[System.M_BOARDER] = new ManagerGeneric(this);
			managers.push(managerMap[System.M_BOARDER]);
			
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
			engine.stage.addEventListener(KeyboardEvent.KEY_UP, upKeyboard);
			
			// load save data
			if (useSave)
			{
				ship.setHP(engine.savedHP);
				level.sectorIndex = engine.maxSector - 1;		// 1 sector before
				gui.mc_progress.setAllSectorProgress(level.sectorIndex);
				if (level.sectorIndex != 0)
					background.setRandomStyle(int(level.sectorIndex / 5), System.getRandCol());
				if (level.sectorIndex <= 7)
					tails.show(TAILS_RELOAD);
				else
				{
					tails.show(HEADS_RELOAD, 0, "HEADS");
					players[0].pdwEnabled = true;
					players[1].pdwEnabled = true;
				}
				// unlock consoles
				if (level.sectorIndex >= 4)
				{
					consoles[0].setLocked(false);
					consoles[1].setLocked(false);
					if (shipName == "Kingfisher")
						consoles[11].setLocked(false);
					else
						consoles[9].setLocked(false);
					consoles[10].setLocked(false);
				}
				if (level.sectorIndex >= 8)
				{
					upgradeTurrets(2);
					gameOverAnnouncer = "HEADS";
				}
				else if (level.sectorIndex >= 4)
					upgradeTurrets(1);
			}
			// new game
			else
			{
				tails.show(TAILS_DEFAULT);
				tails.showNew = true;
				if (shipName == "Kingfisher")
					camera.setCameraFocus(new Point(0, -50));
				else
					camera.setCameraFocus(new Point(0, -100));
			}
			
			stage.focus = game;
			gui.mc_fade.gotoAndPlay(2);		// fade in
			
			//visualEffects.applyBGDistortion(true, "bg_bars");
			/*for (var b:int = 0; b < 10; b++)
			{
				var bpt:Point = getRandomShipLocation();
				addToGame(new BoarderShooter(this, new SWC_Enemy(), shipInsideMask, { "x": bpt.x, "y": bpt.y } ), System.M_BOARDER);
			}*/
		}
		
		public function upgradeTurrets(lvl:int):void
		{
			for (var i:int = (shipName == "Eagle" ? 5 : 6); i >= 2; i--)
				consoles[i].setLevel(lvl);
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
				case System.M_BOARDER:
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
				case Keyboard.ESCAPE:
					if (!completed && gui.mc_win.currentFrame > 1)
					{
						destroy(null);
						return;
					}
					
					if (escDown) return;
					
					escDown = true;
					resetCounter = 0;
					
					if (!isPaused && !isDefeatedPaused)
					{
						isPaused = true;
						justPaused = true;
						SoundManager.pause(true);
						gui.mc_pause.btn_camera.visible = engine.isAllAI();
						gui.mc_pause.mc_autocam.visible = engine.isAllAI();
						gui.mc_pause.mc_autocam.gotoAndStop(useAutoCam ? 2 : 1);
					}
					if (!isDefeatedPaused)
						gui.mc_pause.visible = isPaused;
					if (!justPaused)
					{
						gui.mc_pause.tf_reset.visible = true;
						gui.mc_lose.tf_reset.visible = true;
					}
					
				break;
				
				case Keyboard.J:		// TODO remove temporary testing
					//jump();
				break;
				case Keyboard.K:
					//players[0].changeHP( -9999);
					//ship.damage(1000);
					//killShip();
					//addFires(1);
					//var p:Point = level.getRandomPointInRegion(System.getRandFrom(System.SPAWN_STD));
					//p.x += System.GAME_OFFSX;
					//p.y += System.GAME_OFFSY;
					//level.spawn({}, p, System.getRandFrom(["Eye", "Breeder", "Slime", "Spider"]));
					//level.spawn( { }, p, "Slime");
					//upgradeTurrets(2);
					//ship.shipHeading = System.getRandNum( -1, 1);*/
					//addToGame(new EnemyEyeball(this, new SWC_Enemy(), { "x": -150 + System.GAME_HALF_WIDTH, "y":System.getRandNum(0, 100) + System.GAME_HALF_HEIGHT } ), System.M_ENEMY);
					//addSparks(4);
					//ship.damageDirect(350);
					//var c:ABST_Console = System.getRandFrom(consoles);
					//c.setCorrupt(true);
					//c.debuggable = true;
					//System.getRandFrom(consoles).changeHP( -250);
					//addFires(1);
					//upgradeTurrets(2);
					/*for (var b:int = 0; b < 2; b++)
					{
						var bpt:Point = getRandomShipLocation();
						addToGame(new BoarderShooter(this, new SWC_Enemy(), shipInsideMask, { "x": bpt.x, "y": bpt.y } ), System.M_BOARDER);
					}*/
				break;
			}
		}
		
		private function upKeyboard(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				escDown = false;
				gui.mc_pause.tf_reset.visible = false;
				gui.mc_lose.tf_reset.visible = false;
				
				if (justPaused)
				{
					justPaused = false;
					return;
				}				
				if (resetCounter <= 6)
				{
					if (gui.mc_pause.visible)
					{
						gui.mc_pause.visible = false;
						isPaused = false;
						SoundManager.pause(false);
					}
					else if (gui.mc_lose.visible)
					{
						engine.returnCode = engine.RET_RESTART;
						destroy(null);
					}
				}
				resetCounter = 0;
			}
		}
		
		/**
		 * Evaluates all possible reasons for being paused and returns if the game is actually paused
		 * @return		true if the game is paused for any reason
		 */
		public function isTruePaused():Boolean
		{
			return isPaused || isTailsPaused || isGameOver;
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
		
			SoundManager.step();
			if (escDown && !justPaused && (gui.mc_pause.visible || gui.mc_lose.visible))
			{
				resetCounter++;
				var mc:TextField = gui.mc_pause.visible ? gui.mc_pause.tf_reset : gui.mc_lose.tf_reset;
				if (resetCounter > 35)
					mc.text = "Resetting... 1";
				else if (resetCounter > 20)
					mc.text = "Resetting... 2";
				else if (resetCounter > 6)
					mc.text = "Resetting... 3";
				else
					mc.text = "";
				if (resetCounter == 50)
					destroy(null);
			}
				
			if (!isPaused)
				tails.step();
				
			if (isTruePaused())
			{
				if (players[0] is WINGMAN)
					players[0].step();
				if (players[1] is WINGMAN)
					players[1].step();
				return completed;
			}

			var i:int;
			if (isDefeatedPaused)
			{
				var cf:int = game.mc_ship.mc_shipBase.currentFrame;
				if (!isGameOver && cf == game.mc_ship.mc_shipBase.totalFrames)
				{
					gui.mc_lose.visible = true;
					gui.mc_lose.tf_lose.text = "Ship lost in Sector " + level.sectorIndex;
					isGameOver = true;
				}
				else
				{
					if (cf <= 211 && cf % 5 == 0)
						addExplosions(System.getRandInt(2, 5));
					else if (cf == 228)
						addExplosions(System.getRandInt(8, 16));
					if (cf < 242 && cf % 3 == 0)
					{
						var pt:Point = getRandomShipLocation();
						for (i = System.getRandInt(3, 9); i >= 0; i--)
						{
							
							addDecor("gib_ship", {
														"x": pt.x + System.getRandNum(-5, 5),
														"y": pt.y + System.getRandNum(-5, 5),
														"dx": System.getRandNum( -2, 2),
														"dy": System.getRandNum( -2, 2),
														"dr": System.getRandNum( -15, 15),
														"rot": System.getRandNum(0, 360),
														"scale": System.getRandNum(1, 1.5),
														"alphaDelay": 30 + System.getRandInt(0, 300),
														"alphaDelta": 15,
														"random": true
													});
						}
					}
				}
			}
			
			for (i = 0; i < supportClasses.length; i++)
				supportClasses[i].step();
			
			background.stepBG(atHomeworld() ? 0 : ship.slipSpeed * 150);
			
			for (i = 0; i < managers.length; i++)
				managers[i].step();
				
			if (isAllIncap)
			{
				var minDown:int = Math.min(players[0].reviveCounter, players[1].reviveCounter);
				switch (minDown)
				{
					case System.SECOND * 3:
						tails.show("All crew disabled. Initiate self-destruct sequence.", System.TAILS_NORMAL, "HEADS");
					break;
					case System.SECOND * 9:
						tails.show("Shutting down AI. Scuttling slipship.", System.TAILS_NORMAL, "HEADS");
					break;
					case System.SECOND * 10:
						isAllIncap = false;
						killShip();
					break;
				}
			}
				
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
	
			level.nextSector();
			
			// save state on entering Sector 1, 4, 5, 8, 9, 12
			var mod:int = level.sectorIndex % 4;
			if (mod == 0 || mod == 1)
				engine.saveProgress(level.sectorIndex, ship.getHP());
			
			var boss:Boolean = mod == 0;
			if (level.sectorIndex != 12)
			{
				if (boss)
					SoundManager.playBGM("bgm_boss", System.VOL_BGM);
				else if (level.sectorIndex > 4 && level.sectorIndex < 8)
					SoundManager.playBGM("bgm_notsocalm", System.VOL_BGM);
				else
					SoundManager.playBGM("bgm_calm", System.VOL_BGM);
			}
			
			// show starting TAILS message
			tails.show(level.getTAILS(), boss ? 0 : 120, (level.sectorIndex > 8 ? "HEADS" : null));
			
			// hide all "New!" and console tutorial messages
			for each (var console:ABST_Console in consoles)
				console.showNew( -1);
			gui.mod_p1.mc_tutorial.visible = false;
			gui.mod_p2.mc_tutorial.visible = false;
			
			gui.mc_left.visible = false;
			gui.mc_right.visible = false;

			tails.tutorialMode = false;
			
			game.mc_ship.mc_console_slipdrive.parentClass.setArrowDifficulty(level.sectorIndex);
			ship.minRestore();		// replenish HP
		}
		
		/**
		 * Play the effect for jumping and remove all external objects (but don't actually jump)
		 */
		public function playJumpEffect(label:String = null):void
		{
			SoundManager.playSFX("sfx_slipjump");
			game.mc_jump.gotoAndPlay(label == null ? 2 : label);		// play the jump animation
				
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
			SoundManager.playSFX("sfx_fire_ignited");
		}

		/**
		 * Add num explosions to random valid positions in the ship
		 * @param	num		number of explosions
		 */
		public function addExplosions(num:int):void
		{
			var pos:Point;
			var spawnFX:ABST_Object;
			SoundManager.playSFX("sfx_explosionlarge1");
			for (var i:int = 0; i < num; i++)
			{
				pos = getRandomShipLocation();
				if (pos == null) continue;
				spawnFX = addDecor("spawn", { "x":pos.x, "y":pos.y, "scale":System.getRandNum(0.25, 3) } );
				spawnFX.mc_object.base.setTint(System.COL_ORANGE);
			}
		}
		
		/**
		 * Add fire to the given position in the ship
		 * @param	loc		location of fire
		 */
		public function addFireAt(loc:Point):void
		{
			addToGame(new InternalFire(this, new SWC_Decor(), loc, shipInsideMask), System.M_FIRE);
			SoundManager.playSFX("sfx_fire_ignited");
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
		 * Get a random point around/within the ship
		 * @return		random point
		 */
		public function getRandomNearLocation():Point
		{
			return new Point(System.getRandNum( -450, 450), System.getRandNum( -300, 300));
		}
		
		public function killShip():void
		{
			if (isDefeatedPaused) return;
			isDefeatedPaused = true;
			
			managerMap[System.M_FIRE].killAll();
			managerMap[System.M_BOARDER].killAll();
			
			// hide ship interior
			setInteriorVisibility(false);
			ship.setShieldsEnabled(false);
			
			game.mc_ship.mc_shipBase.gotoAndPlay("death");
			
			if (gameOverAnnouncer == "FAILS")
				tails.show(System.getRandFrom([ "Hah! See ya later, suckers!",
												"See? I TOLD you that you're gonna die!",
												"Big explosion! BIG SUCCESS!"
												]), System.TAILS_NORMAL * 2, "FAILS_talk", true);
			else if (gameOverAnnouncer == "TAILS")
				tails.show(System.getRandFrom([ "Aaah! I'm sorry! I'm sorry...",
												"Oh no! No, no, no!",
												"Eeek! This isn't supposed to happen!"
												]), System.TAILS_NORMAL * 2, null, true);
			else if (gameOverAnnouncer == "HEADS")
				tails.show(System.getRandFrom([ "Ship integrity compromised.",
												"Mission failed.",
												"System failure. Shutting down."
												]), System.TAILS_NORMAL * 2, "HEADS", true);
		}
		
		/**
		 * Show or hide the interior of the ship
		 * @param	vis		true if visible
		 */
		public function setInteriorVisibility(vis:Boolean):void
		{
			game.mc_ship.mc_interior.visible = vis;
			game.mc_ship.shield.visible = vis;
			game.mc_ship.mc_player0.visible = vis;
			game.mc_ship.mc_player1.visible = vis;
			for each (var c:ABST_Console in consoles)
				c.mc_object.visible = vis;
			if (shipName == "Eagle")
			{
				game.mc_ship.turret_f.visible = vis;
				game.mc_ship.turret_l.visible = vis;
				game.mc_ship.turret_r.visible = vis;
				game.mc_ship.turret_b.visible = vis;
			}
			else
			{
				game.mc_ship.turret_lf.visible = vis;
				game.mc_ship.turret_lr.visible = vis;
				game.mc_ship.turret_rf.visible = vis;
				game.mc_ship.turret_r.visible = vis;
				game.mc_ship.turret_rr.visible = vis;
			}
		}
		
		public function reactToFive():void
		{
			if (tails.showDuration > 0 || serious) return;
			if (gameOverAnnouncer == "FAILS")
				tails.show(System.getRandFrom([ "What? Don't high-five! I'M TRYING TO KILL YOU!",
												"You two are even dumber than I thought!",
												"The both of you look like HUGE DORKS, you know..."
												]), System.SECOND * 3, "FAILS_pissed");
			else if (gameOverAnnouncer == "TAILS")
				tails.show(System.getRandFrom([ "Aww, you two are so cute!",
												"Yeah! Keep your spirits up!",
												"I'd high-five you, too! If I had hands, that is...",
												"Woo! I know we can do it!"
												]), System.SECOND * 3, null);
			else
				tails.show(System.getRandFrom([ "Error. Meaning of gesture unknown.",
												"That action is not conducive to mission imperative.",
												"Cease friendship and return to mission."
												]), System.SECOND * 3, "HEADS");
		}
		
		private function onAutoCam(e:MouseEvent):void
		{
			useAutoCam = !useAutoCam;
			gui.mc_pause.mc_autocam.gotoAndStop(useAutoCam ? 2 : 1);
		}
		
		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		protected function destroy(e:Event):void
		{
			if (engine.stage.hasEventListener(KeyboardEvent.KEY_DOWN))
				engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			if (engine.stage.hasEventListener(KeyboardEvent.KEY_UP))
				engine.stage.removeEventListener(KeyboardEvent.KEY_UP, upKeyboard);
			if (gui && gui.mc_pause.btn_camera.hasEventListener(MouseEvent.CLICK))
				gui.mc_pause.btn_camera.removeEventListener(MouseEvent.CLICK, onAutoCam);
			
			var i:int;
			for (i = 0; i < managers.length; i++)
			{
				managers[i].destroy();
				managers[i] = null;
			}
			managers = null;
			
			for (i = 0; i < supportClasses.length; i++)
			{
				supportClasses[i].destroy();
				supportClasses[i] = null;
			}
			supportClasses = null;
				
			if (game != null && contains(game))
				removeChild(game);
			game = null;
			
			SoundManager.shutUp();
			completed = true;
		}
	}
}
