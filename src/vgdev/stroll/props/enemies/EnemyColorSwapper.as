package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_Projectile;
	import vgdev.stroll.props.projectiles.ProjectileGeneric;
	import vgdev.stroll.props.projectiles.ProjectileHardened;
	import vgdev.stroll.System;
	
	/**
	 * Boss enemy that periodically swaps its attack color
	 * @author Alexander Huynh
	 */
	public class EnemyColorSwapper extends ABST_Enemy 
	{
		protected var colorCooldown:int = 0;
		protected const COLOR_COOLDOWN:int = 360;
		
		public function EnemyColorSwapper(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, attributes:Object) 
		{
			super(_cg, _mc_object, _pos, attributes);
			
			cooldowns[0] = int(cooldowns[0] * 1.2);
		}
		
		override public function step():Boolean 
		{
			if (--colorCooldown <= 0)
			{
				colorCooldown = int(COLOR_COOLDOWN * System.getRandNum(.8, 1.2));
				attackColor = System.getRandCol([attackColor]);
			}
			return super.step();
		}
		
		// fire 3 slow bullets in a wave instead of 1
		override protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					cdCounts[i] = cooldowns[i];
					var proj:ABST_Projectile;
					var sway:int = System.getRandInt(8, 12);
					for (var n:int = 0; n < 3; n++)
					{
						proj = new ProjectileHardened(cg, new SWC_Bullet(),
													{	 
														"affiliation":	System.AFFIL_ENEMY,
														"attackColor":	attackColor,
														"dir":			mc_object.rotation + (n - 1) * sway,
														"dmg":			attackStrength,
														"hp":			2,
														"life":			350,
														"pdmg":			2,
														"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
														"spd":			2,
														"style":		null
													});
						proj.mc_object.scaleX = proj.mc_object.scaleY = 3;
						cg.addToGame(proj, System.M_EPROJECTILE);
					}
				}
			}
		}
	}
}