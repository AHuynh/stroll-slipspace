package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.props.projectiles.EProjectileHardened;
	import vgdev.stroll.System;
	
	/**
	 * Beefy but slow enemy with a strong attack and a weaker trishot
	 * @author Alexander Huynh
	 */
	public class EnemySquid extends ABST_Enemy 
	{
		private var forceTP:Boolean = true;		// first time HP is reduced below 50%, free TP
		
		public function EnemySquid(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("squid");
			
			if (mc_object.x > 0)
				mc_object.scaleX = -1;
			
			// [Large shot, Small trishot. TP]
			cdCounts = [45, 90, System.SECOND * 20];
			cooldowns = [100, 140, System.SECOND * 20];
			rangeVary = 50;
			drift = .1;
			spd = .3;
		}

		override protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					cdCounts[i] = cooldowns[i] + System.getRandInt(-40, 60);
					var proj:ABST_EProjectile;
					switch (i)
					{
						case 0:
							proj = new EProjectileHardened(cg, new SWC_Bullet(),
																		{	 
																			"affiliation":	System.AFFIL_ENEMY,
																			"attackColor":	attackColor,
																			"dir":			System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) + System.getRandNum( -10, 10),
																			"rot":			90 * System.getRandInt(0, 3),
																			"dmg":			attackStrength,
																			"hp":			4,
																			"life":			350,
																			"pdmg":			3,
																			"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																			"spd":			1,
																			"style":		"pus"
																		});
							cg.addToGame(proj, System.M_EPROJECTILE);
						break;
						case 1:
							for (var n:int = 0; n < 3; n++)
							{
								proj = new EProjectileGeneric(cg, new SWC_Bullet(),
																		{	 
																			"affiliation":	System.AFFIL_ENEMY,
																			"attackColor":	attackColor,
																			"dir":			System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) + System.getRandNum(-5, 5) + (n - 1) * 30,
																			"rot":			90 * System.getRandInt(0, 3),
																			"dmg":			attackStrength * .2,
																			"life":			150,
																			"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																			"spd":			3,
																			"style":		"pus",
																			"scale":		0.5
																		});
								cg.addToGame(proj, System.M_EPROJECTILE);
							}
						break;
						case 2:		// teleport
							teleport();
						break;
					}
				}
			}
			
			// attack animation
			if (cdCounts[0] == 27)
				mc_object.base.gotoAndPlay("shoot");
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var ret:Boolean = super.changeHP(amt);
			if (forceTP && hp < hpMax * .5)
			{
				forceTP = false;
				teleport();
				cdCounts[2] = cooldowns[2];
			}
			return ret;
		}
		
		private function teleport():void
		{
			if (mc_object == null) return;
			cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale":2 } );
			var p:Point = cg.level.getRandomPointInRegion("near_orbit");
			mc_object.x = p.x;
			mc_object.y = p.y;
			cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale":2 } );
			
			mc_object.scaleX = mc_object.x > 0 ? -1 : 1;
		}
		
		override protected function maintainRange():void
		{				
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			var theta:Number = System.getAngle(cg.shipHitMask.x, cg.shipHitMask.y, mc_object.x, mc_object.y);
			var rot:Number = (theta + 180) % 360;
			//mc_object.rotation = rot;
			var tgtPoint:Point = new Point(orbitX * Math.cos(System.degToRad(theta)),  orbitY * Math.sin(System.degToRad(theta)));
			var tgtDist:Number = System.getDistance(tgtPoint.x, tgtPoint.y, cg.shipHitMask.x, cg.shipHitMask.y);
			
			if (dist > tgtDist + rangeVary)			// too far away
			{
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				driftDir = 1;
			}
			else if (dist < tgtDist - rangeVary)	// too close
			{
				updatePosition(System.forward( -spd, rot, true), System.forward( -spd, rot, false));
				driftDir = -1;
			}
			else									// in-between
				updatePosition(System.forward(drift * driftDir, rot, true), System.forward(drift * driftDir, rot, false));
		}
		
		override public function destroy():void 
		{
			for (var i:int = 7 + System.getRandInt(0, 4); i >= 0; i--)
				cg.addDecor("gib_squid", {
											"x": System.getRandNum(mc_object.x - 35, mc_object.x + 35),
											"y": System.getRandNum(mc_object.y - 25, mc_object.y + 55),
											"dx": System.getRandNum( -1, 1),
											"dy": System.getRandNum( -1, 1),
											"dr": System.getRandNum( -10, 10),
											"rot": System.getRandNum(0, 360),
											"scale": System.getRandNum(1, 2.5),
											"alphaDelay": 120 + System.getRandInt(0, 30),
											"alphaDelta": 45,
											"random": true
										});
			super.destroy();
		}
	}
}