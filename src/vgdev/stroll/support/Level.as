package vgdev.stroll.support 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.*;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.support.splevels.ABST_SPLevel;
	import vgdev.stroll.support.splevels.SPLevelAnomalies;
	import vgdev.stroll.System;
	
	/**
	 * Support functionality related to the level
	 * @author Alexander Huynh
	 */
	public class Level 
	{
		private var cg:ContainerGame;
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
		[Embed(source="../../../../json/en_anomalyfield.json", mimeType="application/octet-stream")]
		private var en_anomalyfield:Class;
		
		[Embed(source = "../../../../json/en_test.json", mimeType = "application/octet-stream")]
		private var en_test:Class;
		[Embed(source="../../../../json/en_test2.json", mimeType="application/octet-stream")]
		private var en_test2:Class;
		[Embed(source = "../../../../json/en_fire_lite.json", mimeType = "application/octet-stream")]
		private var en_fire_lite:Class;
		[Embed(source="../../../../json/en_fire_eyes.json", mimeType="application/octet-stream")]
		private var en_fire_eyes:Class;
		[Embed(source="../../../../json/en_testSurvive.json", mimeType="application/octet-stream")]
		private var en_testSurvive:Class;
		
		/// A map of level names (ex: "test") to level objects
		private var parsedEncounters:Object;
		
		/// The current sector, [0-12]
		private var sectorIndex:int = 0;
		
		private var waves:Array;			// array of wave Objects, each containing a "time" to spawn and
											//    a list of objects to spawn, "spawnables"
		private var waveIndex:int;			// current wave in waves

		private var counter:int = 0;		// keep track of frames elapsed since current encounter started
		private var counterNext:int = 0;	// the "time" that the next wave spawns
		
		private var TAILSmessage:String = "...";
		
		private var spLevel:ABST_SPLevel;	// non-null if using a special level that needs code
		
		public function Level(_cg:ContainerGame)
		{
			cg = _cg;
			
			parsedEncounters = new Object();
			
			// add levels here
			var rawEncountersJSON:Array =	[	
												JSON.parse(new en_intro_waves()),
												JSON.parse(new en_intro_squids()),
												JSON.parse(new en_intro_slimes()),
												JSON.parse(new en_intro_amoebas())
												//JSON.parse(new en_anomalyfield())
												
												/*JSON.parse(new en_test()),
												JSON.parse(new en_test2()),
												JSON.parse(new en_fire_lite()),
												JSON.parse(new en_fire_eyes()),
												JSON.parse(new en_testSurvive())*/
											];
											
											// DEBUGGING A SINGLE ENCOUNTER ONLY
											//rawEncountersJSON = [JSON.parse(new en_anomalyfield())];
			
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
		public function step():void
		{
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
				//trace("[Level] Starting wave at index", waveIndex);
				
				if (waves[waveIndex]["TAILS"] != null)
					cg.tails.show(waves[waveIndex]["TAILS"], System.TAILS_NORMAL);
					
				var repeat:int = waves[waveIndex]["repeat"] == null ? 1 : waves[waveIndex]["repeat"];
				//trace("[Level]\tEnemies to spawn:", (waves[waveIndex]["spawnables"].length * repeat));
				var waveColor:uint = System.getRandCol();
				if (waves[waveIndex]["spawnables"].length != 0)
				{
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
							{
								pos = new Point();
								//trace("[Level] No spawn location defined for", type);
							}

							var spawn:ABST_Object;
							var manager:int;
							switch (type)
							{
								case "Eye":
									spawn = new EnemyEyeball(cg, new SWC_Enemy(), {
																					"x":pos.x,
																					"y":pos.y,
																					"attackColor": col,
																					"hp": 30
																					});
									manager = System.M_ENEMY;
								break;
								case "Squid":
									spawn = new EnemySquid(cg, new SWC_Enemy(), {
																					"x":pos.x,
																					"y":pos.y,
																					"attackColor": col,
																					"attackStrength": 18,
																					"hp": 200
																					});
									manager = System.M_ENEMY;
								break;
								case "Slime":
									spawn = new EnemySlime(cg, new SWC_Enemy(), {
																					"attackColor": col,
																					"attackStrength": 18,
																					"hp": 40
																					});
									manager = System.M_ENEMY;
								break;
								case "Amoeba":
									spawn = new EnemyAmoeba(cg, new SWC_Enemy(), spawnItem["am_size"], {
																					"x":pos.x,
																					"y":pos.y
																					});
									manager = System.M_ENEMY;
								break;
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
								
							case "Fire":
									pos.x -= System.GAME_OFFSX;
									pos.y -= System.GAME_OFFSY;
									spawn = new InternalFire(cg, new SWC_Decor(), pos, cg.shipInsideMask);
									manager = System.M_FIRE;
								break;
							}
							cg.addToGame(spawn, manager);					
						}
					}		
				}
				if (waves[waveIndex]["recur"] != null)			// redo the current wave if "recur" exists
					counterNext = waves[waveIndex]["recur"] * System.SECOND;
				else if (++waveIndex < waves.length)
					counterNext = waves[waveIndex]["time"];		// prepare to spawn the next wave
				counter = 0;
			}

			/*
			var e:ABST_Enemy = new EnemyColorSwapper(cg, new SWC_Enemy, new Point(500, System.getRandNum(-100, 100)), {"attackColor":System.getRandCol(), "attackStrength":10, "hp":300});
			e.setScale(2);
			cg.addToGame(e, System.M_ENEMY);
			cg.ship.jammable = 1;
			}*/
		}

		/**
		 * Load the next sector (encounter)
		 * @return			true if this was the last sector in the game
		 */
		public function nextSector():Boolean
		{
			sectorIndex++;
			var choices:Array = [];
			for each (var e:Object in parsedEncounters)
			{
				if (!System.outOfBounds(sectorIndex, e["difficulty_min"], e["difficulty_max"]))
					choices.push(e);
			}
			
			if (choices.length == 0)		// TODO something when there are no valid encounters
			{
				trace("[Level] WARNING: No suitable encounters found for Sector", sectorIndex);
				return false;
			}

			var encounter:Object = choices[int(System.getRandInt(0, choices.length - 1))];
			trace("Starting encounter called: '" + encounter["id"] + "'");
			
			if (encounter["spLevel"] != null)
			{
				switch (encounter["spLevel"])
				{
					case "anomalies":
						spLevel = new SPLevelAnomalies(cg);
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
			
			cg.ship.slipRange = encounter["slip_range"];
			cg.ship.jammable = encounter["jamming_min"];
			TAILSmessage = encounter["TAILS"];

			counter = 0;					// reset time elapsed in this encounter		
			
			// update progress meter
			cg.gui.mc_progress.setSectorProgress(sectorIndex);
			
			return sectorIndex > 12;		// TODO end state
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
		private function getRandomPointInRegion(region:String):Point
		{
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
				default:
					trace("[Level] Region not known:", region);
					return new Point();
			}
		}
	}
}