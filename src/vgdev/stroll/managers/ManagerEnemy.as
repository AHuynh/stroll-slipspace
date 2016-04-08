package vgdev.stroll.managers 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.System;
	
	/**
	 * Manager for ABST_Enemy that takes into account jamming values
	 * @author Alexander Huynh
	 */
	public class ManagerEnemy extends ABST_Manager 
	{
		
		public function ManagerEnemy(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function numObjects():int 
		{
			var total:int = 0;
			for each (var enemy:ABST_Enemy in objArray)
				total += enemy.getJammingValue();
			return total;
		}
		
		// don't kill stubborn enemies
		override public function killAll():void
		{
			if (objArray)
				for (var i:int = objArray.length - 1; i >= 0; i--)
					if (!objArray[i].stubborn)
					{
						objArray[i].destroySilently();
						objArray.splice(i, 1);
					}
		}
		
		/**
		 * Given an object, determines if it has collided with another object in this manager.
		 * @param	o			The object to check for
		 * @param	precise		Whether to use distance checking (false), or pixel-perfect checking (true)
		 * @return				The first ABST_Object that o is colliding with, else null
		 */
		override public function collideWithOther(o:ABST_Object, precise:Boolean = false):ABST_Object
		{
			if (!objArray) return null;
			if (!o.isActive())
				return null;
			var other:ABST_Enemy;
			var hitbox:MovieClip;
			for (var i:int = 0; i < objArray.length; i++)
			{
				other = objArray[i];
				if (!other.isActive() || collisionException(o, other))
					continue;
				hitbox = other.hitbox == null ? other.mc_object : other.hitbox;
				if (System.getDistance(o.mc_object.x, o.mc_object.y, other.mc_object.x, other.mc_object.y) < Math.max(o.mc_object.width, other.mc_object.width))
				{
					if (!precise || hitbox.hitTestPoint(o.mc_object.x + System.GAME_OFFSX, o.mc_object.y + System.GAME_OFFSY, true))
						return other;
				}
			}
			return null;
		}
	}
}