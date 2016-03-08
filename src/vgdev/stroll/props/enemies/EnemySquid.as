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
		public function EnemySquid(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("squid");
			
			// [Large shot, Small trishot]
			cdCounts = [45, 90];
			cooldowns = [120, 160];
			ranges = [390, 430];
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
																			"dir":			System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) + System.getRandNum(-10, 10),
																			"dmg":			attackStrength,
																			"hp":			4,
																			"life":			350,
																			"pdmg":			3,
																			"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																			"scale":		2,
																			"spd":			1,
																			"style":		null
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
																			"dmg":			attackStrength * .2,
																			"life":			150,
																			"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																			"spd":			3,
																			"style":		null
																		});
								cg.addToGame(proj, System.M_EPROJECTILE);
							}
						break;
					}
				}
			}
			
			// attack animation
			if (cdCounts[0] == 27)
				mc_object.base.gotoAndPlay("shoot");
		}
		
		override protected function maintainRange():void
		{
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			var rot:Number = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			//mc_object.rotation = rot;
			mc_object.scaleX = mc_object.x > 0 ? -1 : 1;
			if (dist < ranges[0])
			{
				updatePosition(System.forward( -spd, rot, true), System.forward( -spd, rot, false));
				driftDir = -1;
			}
			else if (dist > ranges[1])
			{
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				driftDir = 1;
			}
			else
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