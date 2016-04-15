package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.System;
	
	/**
	 * Final boss mechanic
	 * @author Alexander Huynh
	 */
	public class EnemyCrystal extends ABST_Enemy 
	{
		public static var dTheta:Number = 0.1;
		public static var globalTheta:Number = 0;
		public static var numCrystals:int = 0;
		private var isAnchor:Boolean = false;
		
		private var ELLIPSE_A:Number;
		private var ELLIPSE_B:Number;
		
		private var theta:Number;
		
		private var corrupted:int = -1;		// -1 FAILS, 0 neutral, 1 TAILS
		public static var totalNumCorrupted:int = 0;
		
		public function EnemyCrystal(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;		// do it after updating position
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("crystal");
			mc_object.base.mc_glow.visible = false;
			
			ELLIPSE_A = System.ORBIT_1_X - 70;
			ELLIPSE_B = System.ORBIT_1_Y - 45;
			
			theta = System.setAttribute("theta", attributes, 0);
			if (numCrystals++ == 0)
			{
				isAnchor = true;
				globalTheta = theta;
			}
			totalNumCorrupted--;		// add -1 to corruption count
			
			hp = hpMax = 150;
			stubborn = true;
			
			// AoE weapon, particle effect
			cdCounts = [0, 0];
			cooldowns = [180, 10];
			
			updatePosition(0, 0);
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "rot": System.getRandNum(0, 360), "scale": 4 } );
			spawnFX.mc_object.base.setTint(System.COL_RED);
			
			setBaseColor(System.COL_RED);
		}
		
		override protected function setBaseColor(col:uint):void
		{
			selfColor = col;			
			ct.redMultiplier = Math.min(selfColor >> 16 & 0x0000FF / 255, (0xFF / 255) * colAlpha);
			ct.greenMultiplier = Math.min(selfColor >> 8 & 0x0000FF / 255, (0xFF / 255) * colAlpha);
			ct.blueMultiplier = selfColor & 0x0000FF / 255;
			if (mc_object != null)
				mc_object.base.transform.colorTransform = ct;
		}
		
		override public function step():Boolean
		{
			if (!completed && mc_object != null)
			{
				updatePrevPosition();
				updatePosition(dX, dY);
				if (corrupted != 1)
					updateDamageFlash();
				updateWeapons();
			}
			return completed;
		}
		
		/**
		 * If blue, turn to white; if white, turn to red; if red, do nothing; if blue and force, turn to red
		 */
		public function corrupt(force:Boolean = false):void
		{
			if (force && corrupted == 1)	// corrupt twice if blue
				corrupt(false);
				
			playBlastEffect();
			
			switch (corrupted)
			{
				case -1:		return;
				case 0:
					corrupted = -1;
					totalNumCorrupted--;
					setBaseColor(System.COL_RED);
					hp = hpMax = 150;
				break;
				case 1:
					corrupted = 0;
					totalNumCorrupted--;
					setBaseColor(System.COL_WHITE);
					hp = hpMax = 80;
				break;
			}
		}
		
		public function playBlastEffect():void
		{
			mc_object.base.mc_blast.gotoAndPlay("blast");
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var ret:Boolean = super.changeHP(amt);
			if (ret)
			{
				switch (corrupted)
				{
					case -1:			// neutral
						corrupted = 0;
						setBaseColor(System.COL_WHITE);
						spawnParticleRing(System.COL_WHITE);
						totalNumCorrupted++;
						hp = hpMax = 80;
					break;
					case 0:				// TAILS
						corrupted = 1;
						setBaseColor(System.COL_TAILS);
						spawnParticleRing(System.COL_TAILS);
						totalNumCorrupted++;
						hp = hpMax = 1;
					break;
					case 1:				// AoE
						if (cdCounts[0] == 0)
						{
							cdCounts[0] = cooldowns[0];
							var proj:EProjectileGeneric;
							for (var n:int = 0; n < 16; n++)
							{
								proj = new EProjectileGeneric(cg, new SWC_Bullet(),
																		{	 
																			"affiliation":	System.AFFIL_PLAYER,
																			"dir":			n * 22.5,
																			"dmg":			20,
																			"life":			150,
																			"pos":			mc_object.localToGlobal(new Point(
																									mc_object.spawn.x + 20 * Math.cos(System.degToRad(n * 22.5)),
																									mc_object.spawn.y + 20 * Math.sin(System.degToRad(n * 22.5)))),
																			"spd":			4,
																			"style":		"crystal"
																		});
								cg.addToGame(proj, System.M_EPROJECTILE);
							}
						}
						mc_object.base.mc_glow.visible = false;
					break;
				}
			}
			return ret;
		}
		
		/**
		 * Create a ring of 16 diamond particles
		 * @param	col		Color of particles
		 */
		private function spawnParticleRing(col:uint):void
		{
			for (var n:int = 0; n < 16; n++)
				cg.addDecor("crystal_shard", {
											"x": mc_object.x,
											"y": mc_object.y,
											"dx": 6 * Math.cos(System.degToRad(n * 22.5)),
											"dy": 6 * Math.sin(System.degToRad(n * 22.5)),
											"alphaDelay": 90,
											"alphaDelta": 30,
											"scale": 0.5,
											"tint": col
										});
		}
		
		override protected function updateWeapons():void 
		{
			if (corrupted == 1 && cdCounts[0] > 0)
				if (--cdCounts[0] == 0)
					mc_object.base.mc_glow.visible = true;
			if (corrupted != 0 && --cdCounts[1] <= 0)
			{
				cdCounts[1] = cooldowns[1] + System.getRandInt(0, 10);
				var theta:Number = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) + System.getRandNum(-15, 15);
				cg.addDecor("crystal_shard", {
											"x": mc_object.x,
											"y": mc_object.y,
											"dx": System.forward(6, theta, true),
											"dy": System.forward(6, theta, false),
											"alphaDelay": 60,
											"alphaDelta": 30,
											"scale": 0.5,
											"tint": corrupted == -1 ? System.COL_RED : System.COL_TAILS
										});
			}
		}
		
		// parameters don't matter here
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			theta = (theta + dTheta) % 360;
			if (isAnchor)
				globalTheta = theta;
			mc_object.x = ELLIPSE_A * Math.cos(System.degToRad(theta));
			mc_object.y = ELLIPSE_B * Math.sin(System.degToRad(theta));
		}
		
		/**
		 * Really kill this enemy
		 */
		public function trueDestroy():void
		{
			stubborn = true;
		}
		
		/**
		 * Don't actually die unless stubborn is false (call trueDestroy())
		 */
		override public function destroy():void 
		{
			if (stubborn) return;
			super.destroy();
		}
	}
}