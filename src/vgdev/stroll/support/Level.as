package vgdev.stroll.support 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.*;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.support.splevels.*;
	import vgdev.stroll.System;
	
	/**
	 * Support functionality related to the level
	 * @author Alexander Huynh
	 */
	public class Level extends ABST_Support
	{
		private var timeline:int = 0;
		
		// -- EASY REGION ---------------------------------------------------------------------------------------
		[Embed(source="../../../../json/en_intro_waves.json", mimeType="application/octet-stream")]
		private var en_intro_waves:Class;
		[Embed(source="../../../../json/en_intro_squids.json", mimeType="application/octet-stream")]
		private var en_intro_squids:Class;
		[Embed(source="../../../../json/en_intro_slimes.json", mimeType="application/octet-stream")]
		private var en_intro_slimes:Class;
		[Embed(source="../../../../json/en_intro_amoebas.json", mimeType="application/octet-stream")]
		private var en_intro_amoebas:Class;
		[Embed(source="../../../../json/en_anomalyfieldplain.json", mimeType="application/octet-stream")]
		private var en_anomalyfieldplain:Class;
		
		// -- MEDIUM REGION -------------------------------------------------------------------------------------
		[Embed(source="../../../../json/en_swipe.json", mimeType="application/octet-stream")]
		private var en_swipe:Class;
		[Embed(source="../../../../json/en_anomalyfieldcolored.json", mimeType="application/octet-stream")]
		private var en_anomalyfieldcolored:Class;
		[Embed(source="../../../../json/en_skulls.json", mimeType="application/octet-stream")]
		private var en_skulls:Class;
		[Embed(source="../../../../json/en_mantas.json", mimeType="application/octet-stream")]
		private var en_mantas:Class;
		[Embed(source="../../../../json/en_breeders.json", mimeType="application/octet-stream")]
		private var en_breeders:Class;
		
		// -- HARD REGION ---------------------------------------------------------------------------------------
		[Embed(source="../../../../json/en_fire_ice.json", mimeType="application/octet-stream")]
		private var en_fire_ice:Class;
		[Embed(source="../../../../json/en_spiders.json", mimeType="application/octet-stream")]
		private var en_spiders:Class;
		[Embed(source="../../../../json/en_rainbow.json", mimeType="application/octet-stream")]
		private var en_rainbow:Class;	
		
		// -- BOSS REGIONS --------------------------------------------------------------------------------------
		[Embed(source="../../../../json/en_boss_peeps.json", mimeType="application/octet-stream")]
		private var en_boss_peeps:Class;
		[Embed(source="../../../../json/en_boss_fails.json", mimeType="application/octet-stream")]
		private var en_boss_fails:Class;
		[Embed(source="../../../../json/en_boss_final.json", mimeType="application/octet-stream")]
		private var en_boss_final:Class;
		
		/// A map of level names (ex: "test") to level objects
		private var parsedEncounters:Object;
		
		/// The current sector, [0-12]
		public var sectorIndex:int = 0;
		
		private var waves:Array;			// array of wave Objects, each containing a "time" to spawn and
											//    a list of objects to spawn, "spawnables"
		private var waveIndex:int;			// current wave in waves
		private var waveColor:uint;
		private var fireSound:Boolean = true;

		private var counter:int = 0;		// keep track of frames elapsed since current encounter started
		private var counterNext:int = 0;	// the "time" that the next wave spawns
		
		private var TAILSmessage:String = "...";
		
		private var spLevel:ABST_SPLevel;	// non-null if using a special level that needs code
		
		public function Level(_cg:ContainerGame)
		{
			super(_cg);
			
			parsedEncounters = new Object();
			
			// add levels here
			var rawEncountersJSON:Array =	[	
												JSON.parse(new en_intro_waves()),
												JSON.parse(new en_intro_squids()),
												JSON.parse(new en_intro_slimes()),
												JSON.parse(new en_intro_amoebas()),
												JSON.parse(new en_anomalyfieldplain()),
												
												JSON.parse(new en_boss_peeps()),
												
												JSON.parse(new en_anomalyfieldcolored()),
												JSON.parse(new en_swipe()),
												JSON.parse(new en_skulls()),
												JSON.parse(new en_mantas()),
												JSON.parse(new en_breeders()),
											
												JSON.parse(new en_boss_fails()),
												
												JSON.parse(new en_spiders()),
												JSON.parse(new en_fire_ice()),
												JSON.parse(new en_rainbow()),
												
												JSON.parse(new en_boss_final())
											];
											
											// DEBUGGING A SINGLE ENCOUNTER ONLY
											// (you must also CTRL+F and comment out the line containing [COMMENTME] to ignore sector constraints)
											//rawEncountersJSON = [JSON.parse(new en_boss_final())];
			
			// parse all the encounters and save them
			for each (var rawEncounter:Object in rawEncountersJSON)
			{
				var parsedEncounter:Object = new Object();
				
				parsedEncounter["id"] = rawEncounter["settings"]["id"];
				parsedEncounter["slip_range"] = rawEncounter["settings"]["slip_range"];
				parsedEncounter["jamming_min"] = rawEncounter["settings"]["jamming_min"];
				parsedEncounter["difficulty_min"] = rawEncounter["settings"]["difficulty_range"][0];
				parsedEncounter["difficulty_max"] = rawEncounter["settings"]["difficulty_range"][1];
				parsedEncounter["TAILS"] = rawEncounter["settings"]["TAILS"];
				parsedEncounter["spLevel"] = rawEncounter["settings"]["spLevel"];
				
				// set up object waves
				parsedEncounter["spawnables"] = [];
				for each (var waveJSON:Object in rawEncounter["waves"])
				{
					var waveObj:Object = new Object();
					waveObj["time"] = int(waveJSON["time"] * System.SECOND);		// the RELATIVE time to wait since the start of the previous wave
					waveObj["spawnables"] = waveJSON["spawnables"];
					if (waveJSON["recur"] != null)
						waveObj["recur"] = waveJSON["recur"];				// loop this wave forever
					if (waveJSON["repeat"] != null)
						waveObj["repeat"] = waveJSON["repeat"];				// spawn the spawnables in this wave 'repeat' times
					if (waveJSON["TAILS"] != null)
						waveObj["TAILS"] = waveJSON["TAILS"];				// display a TAILS message
					parsedEncounter["spawnables"].push(waveObj);
				}
			
				parsedEncounters[parsedEncounter["id"]] = parsedEncounter;
			}
		}
	
		/**
		 * Handle the spawning of objects in the current encounter
		 */
		override public function step():void
		{
			timeline++;
			// hand control over to special level class if one exists for this encounter
			if (spLevel != null)
			{
				spLevel.step();
				return;
			}
			
			// quit if there are no more things happening
			if (waves == null || waveIndex == waves.length)
				return;
			
			// if we're at the next time to spawn things
			if (++counter >= counterNext)
			{				
				if (waves[waveIndex]["TAILS"] != null)
					cg.tails.show(waves[waveIndex]["TAILS"], System.TAILS_NORMAL, (sectorIndex > 8 ? "HEADS" : null));
					
				var repeat:int = waves[waveIndex]["repeat"] == null ? 1 : waves[waveIndex]["repeat"];
				waveColor = System.getRandCol();
				if (waves[waveIndex]["spawnables"].length != 0)
				{
					fireSound = true;
					for (var r:int = 0; r < repeat; r++)
					{
						// iterate over things to spawn
						for each (var spawnItem:Object in waves[waveIndex]["spawnables"])
						{
							var type:String = spawnItem["type"];
							var col:uint = System.stringToCol(spawnItem["color"]);
							
							var pos:Point;
							if (spawnItem["region"] != null)
								pos = getRandomPointInRegion(spawnItem["region"]).add(new Point(System.GAME_OFFSX, System.GAME_OFFSY));
							else if (spawnItem["x"] != null && spawnItem["y"] != null)
								pos = new Point(spawnItem["x"] + System.GAME_OFFSX, spawnItem["y"] + System.GAME_OFFSY);
							else
								pos = new Point();

							spawn(spawnItem, pos, type, col);		
						}
					}		
				}
				if (waves[waveIndex]["recur"] != null)			// redo the current wave if "recur" exists
					counterNext = waves[waveIndex]["recur"] * System.SECOND;
				else if (++waveIndex < waves.length)
					counterNext = waves[waveIndex]["time"];		// prepare to spawn the next wave
				counter = 0;
			}
		}
		
		/**
		 * Spawn an enemy
		 * @param	spawnItem		Additional spawn parameters
		 * @param	pos				Location to spawn at
		 * @param	type			Type of enemy
		 */
		public function spawn(spawnItem:Object, pos:Point, type:String, col:uint = System.COL_WHITE):ABST_Object
		{
			var spawn:ABST_Object;
			var manager:int;
			switch (type)
			{
				case "Amoeba":
					spawn = new EnemyAmoeba(cg, new SWC_Enemy(), spawnItem["am_size"], {
																	"x":pos.x,
																	"y":pos.y,
																	"collideColor": System.COL_GREEN
																	});
					manager = System.M_ENEMY;
				break;
				case "Breeder":
					spawn = new EnemyBreeder(cg, new SWC_Enemy(), {
																	"attackColor": System.COL_GREEN,
																	"attackStrength": System.getRandInt(6, 13),
																	"hp": 120,
																	"x":pos.x,
																	"y":pos.y
																	});
					manager = System.M_ENEMY;
				break;
				case "Eye":
					spawn = new EnemyEyeball(cg, new SWC_Enemy(), {
																	"x":pos.x,
																	"y":pos.y,
																	"attackColor": System.COL_RED,
																	"hp": 30
																	});
					manager = System.M_ENEMY;
				break;
				case "FloaterFire":
					spawn = new BoarderSuicider(cg, new SWC_Enemy(), cg.shipInsideMask, {});
					manager = System.M_BOARDER;
				break;
				case "GeometricAnomalyPlain":
					waveColor = System.COL_WHITE;
				case "GeometricAnomaly":
					spawn = new EnemyGeometricAnomaly(cg, new SWC_Enemy(), {
																	"x": System.getRandNum(0, 100) + System.GAME_WIDTH + System.GAME_OFFSX,
																	"y": System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) + System.GAME_OFFSY,
																	"tint": waveColor,
																	"dx": -3 - System.getRandNum(0, 1),
																	"hp": 12
																	});
					manager = System.M_ENEMY;
				break;
				case "Manta":
					spawn = new EnemyManta(cg, new SWC_Enemy(), {
																	"attackColor": System.COL_BLUE,
																	"attackStrength": 25,
																	"hp": 70
																	});
					manager = System.M_ENEMY;
				break;
				case "Skull":
					spawn = new EnemySkull(cg, new SWC_Enemy(), {
																	"attackColor": System.COL_RED,
																	"attackStrength": 15,
																	"hp": 16
																	});
					manager = System.M_ENEMY;
				break;
				case "Slime":
					spawn = new EnemySlime(cg, new SWC_Enemy(), {
																	"attackColor": System.COL_BLUE,
																	"attackStrength": 10,
																	"hp": 30
																	});
					manager = System.M_ENEMY;
				break;
				case "Spider":
					spawn = new EnemySpider(cg, new SWC_Enemy(), {
																	"x":pos.x,
																	"y":pos.y,
																	"attackColor": System.COL_YELLOW,
																	"attackStrength": 20,
																	"hp": 100
																	});
					manager = System.M_ENEMY;
				break;
				case "Squid":
					spawn = new EnemySquid(cg, new SWC_Enemy(), {
																	"x":pos.x,
																	"y":pos.y,
																	"attackColor": System.COL_YELLOW,
																	"attackStrength": 18,
																	"hp": 125
																	});
					manager = System.M_ENEMY;
				break;
				case "Swipe":
					spawn = new EnemySwipe(cg, new SWC_Enemy(), {
																	"attackStrength": 65
																	});
					manager = System.M_ENEMY;
				break;
				case "Peeps":
					spawn = new EnemyPeeps(cg, new SWC_Enemy(), {});
					manager = System.M_ENEMY;
				break;
				case "Portal":
					spawn = new EnemyPortal(cg, new SWC_Enemy(), {
																	"x": pos.x,
																	"y": pos.y,
																	"hp": 450
																	});
					manager = System.M_ENEMY;
				break;
				case "Fire":
					pos.x -= System.GAME_OFFSX;
					pos.y -= System.GAME_OFFSY;
					spawn = new InternalFire(cg, new SWC_Decor(), pos, cg.shipInsideMask);
					manager = System.M_FIRE;
					if (fireSound)
						SoundManager.playSFX("sfx_fire_ignited");
					fireSound = false;
				break;
			}
			return cg.addToGame(spawn, manager);	
		}

		/**
		 * Load the next sector (encounter)
		 * @return			true if this was the last sector in the game
		 */
		public function nextSector():Boolean
		{
			sectorIndex++;
			
			if (sectorIndex == 13)
				return true;
			
			if (spLevel)
			{
				spLevel.destroy();
				spLevel = null;
			}
			var choices:Array = [];
			for each (var e:Object in parsedEncounters)
			{
				if (e["used"] == null && !System.outOfBounds(sectorIndex, e["difficulty_min"], e["difficulty_max"]))		// [COMMENTME]
					choices.push(e);
			}
			
			if (choices.length == 0)		// no valid encounters
			{
				trace("[Level] WARNING: No suitable encounters found for Sector", sectorIndex);
				return false;
			}

			var choiceIndex:int = int(System.getRandInt(0, choices.length - 1));
			var encounter:Object = choices[choiceIndex];
			parsedEncounters[choices[choiceIndex]["id"]]["used"] = true;
			trace("Starting encounter called: '" + encounter["id"] + "'");
			
			cg.ship.slipRange = encounter["slip_range"];
			cg.ship.jammable = encounter["jamming_min"];
			TAILSmessage = encounter["TAILS"];
			
			if (encounter["spLevel"] != null)
			{
				switch (encounter["spLevel"])
				{
					case "anomaliesColored":
						spLevel = new SPLevelAnomalies(cg, true);
					break;
					case "anomaliesPlain":
						spLevel = new SPLevelAnomalies(cg, false);
					break;
					case "rainbow":
						spLevel = new SPLevelRainbow(cg);
					break;
					case "bossPeeps":
						spLevel = new SPLevelPeeps(cg);
					break;
					case "bossFails":
						spLevel = new SPLevelFAILS(cg);
					break;
					case "bossFinal":
						spLevel = new SPLevelFinal(cg);
					break;
					default:
						trace("[LEVEL] Warning: No class found for spLevel:", encounter["spLevel"]);
				}
			}
			else
			{
				spLevel = null;
				waves = encounter["spawnables"];
				counterNext = waves[0]["time"];
			}
			
			waveIndex = 0;
			counter = 0;					// reset time elapsed in this encounter		
			
			// update progress meter
			cg.gui.mc_progress.setSectorProgress(sectorIndex);
	
			if (sectorIndex == 4)
				cg.background.setStyle("peeps");
			else
				cg.background.setRandomStyle(int(sectorIndex / 5), System.getRandCol());
			
			return sectorIndex == 13;
		}
		
		public function getTAILS():String
		{
			return TAILSmessage;
		}
		
		/**
		 * Gets a spawn location in the given region, for the Eagle ship
		 * @param	region		String indicating region (ex: "top_right")
		 * @return				Point, a valid spawn point
		 */
		public function getRandomPointInRegion(region:String):Point
		{
			var theta:Number;
			switch (region)
			{
				case "right":			return new Point(System.getRandNum( 290,  400), System.getRandNum(-150,  150));	break;
				case "far_right":		return new Point(System.getRandNum( 400,  450), System.getRandNum(-150,  150));	break;
				case "top_right":		return new Point(System.getRandNum( 100,  400), System.getRandNum(-250, -170));	break;
				case "bottom_right":	return new Point(System.getRandNum( 100,  400), System.getRandNum( 170,  250));	break;
				case "top":				return new Point(System.getRandNum(-250,  250), System.getRandNum(-250, -170));	break;
				case "far_top":			return new Point(System.getRandNum(-250,  250), System.getRandNum(-300, -260));	break;
				case "bottom":			return new Point(System.getRandNum(-250,  250), System.getRandNum( 170,  250));	break;
				case "far_bottom":		return new Point(System.getRandNum(-250,  250), System.getRandNum( 300,  260));	break;
				case "top_left":		return new Point(System.getRandNum(-400, -230), System.getRandNum(-250, -120));	break;
				case "bottom_left":		return new Point(System.getRandNum(-400, -230), System.getRandNum( 250,  120));	break;
				case "left":			return new Point(System.getRandNum(-450, -300), System.getRandNum(-200,  200));	break;
				case "far_left":		return new Point(System.getRandNum(-450, -400), System.getRandNum(-200,  200));	break;
				case "near_orbit":
					theta = System.getRandNum(0, 360);
					return new Point((System.ORBIT_0_X + System.getRandNum( -30, 50)) * Math.cos(System.degToRad(theta)),
									 (System.ORBIT_0_Y + System.getRandNum( -10, 40)) * Math.sin(System.degToRad(theta)));
				break;
				case "medium_orbit":
					theta = System.getRandNum(0, 360);
					return new Point((System.ORBIT_1_X + System.getRandNum( -40, 50)) * Math.cos(System.degToRad(theta)),
									 (System.ORBIT_1_Y + System.getRandNum( -20, 30)) * Math.sin(System.degToRad(theta)));
				break;
				case "distant_orbit":
					theta = System.getRandNum(0, 360);
					return new Point((System.ORBIT_2_X + System.getRandNum( -70, 40)) * Math.cos(System.degToRad(theta)),
									 (System.ORBIT_2_Y + System.getRandNum( -50, 0)) * Math.sin(System.degToRad(theta)));
				break;
				default:
					trace("[Level] Region not known:", region);
					return new Point();
			}
		}
		
		public function getCounter():int
		{
			return timeline;
		}
		
		override public function destroy():void 
		{
			parsedEncounters = null;
			spLevel = null;
			super.destroy();
		}
	}
}