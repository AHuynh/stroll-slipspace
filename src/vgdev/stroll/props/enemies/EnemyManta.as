package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.props.projectiles.EProjectileHardened;
	import vgdev.stroll.System;
	
	/**
	 * An enemy that constantly orbits the ship and shoots from a distance.
	 * @author Alexander Huynh
	 */
	public class EnemyManta extends ABST_Enemy 
	{
		private var ELLIPSE_A:Number;
		private var ELLIPSE_B:Number;
		
		private var theta:Number;
		private var dTheta:Number;
		
		public function EnemyManta(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;		// do it after updating position
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("manta");
			mc_object.scaleY = Math.random() > .5 ? -1 : 1;
			
			ELLIPSE_A = System.ORBIT_2_X + System.getRandNum(-90, 50);
			ELLIPSE_B = System.ORBIT_2_Y + System.getRandNum(-70, 35);
			
			theta = System.getRandNum(0, 360);
			dTheta = System.getRandNum(0.2, 0.3) * (Math.random() > .5 ? -1 : 1);
			
			cdCounts = [60];
			cooldowns = [180 + System.getRandInt(0, 60)];
			
			updatePosition(0, 0);
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "rot": System.getRandNum(0, 360), "scale": mc_object.scaleX * 2 } );
			spawnFX.mc_object.base.setTint(attackColor);
		}
		
		override public function getJammingValue():int 
		{
			return 2;
		}
		
		// parameters don't matter here
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			theta = (theta + dTheta) % 360;
			mc_object.x = ELLIPSE_A * Math.cos(System.degToRad(theta));
			mc_object.y = ELLIPSE_B * Math.sin(System.degToRad(theta));
			
			mc_object.rotation = System.radToDeg(Math.atan2(mc_object.y, mc_object.x)) + (dTheta > 0 ? 90 : -90);
		}
		
		override protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var spawn:Point = mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y))
					var atkAngle:Number = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x + System.getRandNum( -20, 20), cg.shipHitMask.y + System.getRandNum( -20, 20));
					var proj:EnemyRammable = new EnemyRammable(cg, new SWC_Enemy(),
																	{
																		"collideColor":	attackColor,
																		"hp":			System.getRandInt(9, 15),
																		"attackCollide":attackStrength,
																		"x":			spawn.x,
																		"y":			spawn.y,
																		"atkDir":		atkAngle,
																		"dr":			System.getRandNum(-1, 1),
																		"spd":			System.getRandNum(0.7, 1.1),
																		"style":		"ice",
																		"gib":			"gib_ice",
																		"random":		true
																	});
					cg.addToGame(proj, System.M_ENEMY);
				}
			}
		}
		
		override protected function maintainRange():void 
		{
			// do nothing
			return;
		}
		
		override public function destroy():void 
		{
			for (var i:int = 6 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_manta", {
											"x": System.getRandNum(mc_object.x - 30, mc_object.x + 30),
											"y": System.getRandNum(mc_object.y - 30, mc_object.y + 30),
											"dx": System.getRandNum( -2, 2),
											"dy": System.getRandNum( -2, 2),
											"dr": System.getRandNum( -2, 2),
											"rot": System.getRandNum(0, 360),
											"scale": System.getRandNum(1, 3),
											"alphaDelay": 90 + System.getRandInt(0, 20),
											"alphaDelta": 45,
											"random": true
										});
			super.destroy();
		}
	}
}