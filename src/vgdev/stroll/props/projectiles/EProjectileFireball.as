package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Projectile that does minimal hull damage, but has high chance of fire
	 * Also speeds up over time
	 * @author Alexander Huynh
	 */
	public class EProjectileFireball extends ABST_EProjectile 
	{
		private var dr:Number;
		
		public function EProjectileFireball(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			System.tintObject(mc_object, System.COL_WHITE);		// un-tint since base sprite is already red
			dr = System.getRandNum(5, 10) * (Math.random () > .5 ? 1 : -1);
		}
		
		override public function step():Boolean 
		{
			if (mc_object != null)
			{
				spd *= 1.05;
				mc_object.rotation += dr;
			}
			return super.step();
		}
		
		// 100% shield damage
		//  90% reduced hull damage
		//  15% chance of fire if shields are up
		//  35% chance of fire if shields are down
		override protected function onShipHit():void
		{
			addShipDebris();
			var shieldsUp:Boolean = cg.ship.getShields() > 0;
			cg.ship.damage(dmg * (shieldsUp ? 1 : .1), attackColor);
			if ((shieldsUp && Math.random() < .15) || (!shieldsUp && Math.random() < .35))
				cg.addFires(1);
		}
	}
}