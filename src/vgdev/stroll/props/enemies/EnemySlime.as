package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.System;
	
	/**
	 * An enemy that constantly orbits the ship and shoots.
	 * @author Alexander Huynh
	 */
	public class EnemySlime extends ABST_Enemy 
	{
		private var ELLIPSE_A:Number;
		private var ELLIPSE_B:Number;
		
		private var theta:Number;
		private var dTheta:Number;
		
		public function EnemySlime(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle("slime");
			mc_object.scaleY = Math.random() > .5 ? -1 : 1;
			
			ELLIPSE_A = 420 + System.getRandNum(0, 50);
			ELLIPSE_B = 220 + System.getRandNum(0, 35);
			
			theta = System.getRandNum(0, 360);
			dTheta = System.getRandNum(0.3, 0.7) * (Math.random() > .5 ? -1 : 1);
			
			cdCounts = [60];
			cooldowns = [100];
			
			updatePosition(0, 0);
		}
		
		// parameters don't matter here
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			theta = (theta + dTheta) % 360;
			mc_object.x = ELLIPSE_A * Math.cos(System.degToRad(theta));
			mc_object.y = ELLIPSE_B * Math.sin(System.degToRad(theta));
			
			mc_object.rotation = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x + System.getRandNum(-20, 20), cg.shipHitMask.y + System.getRandNum(-20, 20));
		}
		
		override protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var proj:ABST_EProjectile = new EProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation + System.getRandNum(-10, 10),
																		"dmg":			attackStrength,
																		"life":			150,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			3,
																		"style":		null
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
			if (cdCounts[0] == 11)
				mc_object.base.gotoAndPlay("shoot");
		}
		
		override protected function maintainRange():void 
		{
			// do nothing
			return;
		}
	}
}