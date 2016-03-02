package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.props.Decor;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * A (single) fire on-board the ship
	 * @author Alexander Huynh
	 */
	public class InternalFire extends ABST_IMovable 
	{
		/// Minimum pixel distance to a player to apply damage
		private var FIRE_RANGE:int = 40;
		
		/// Maximum amount of HP damage to apply per tick; scales off of distance
		private var FIRE_DAMAGE:Number = -0.1;
		
		/// Frames until the fire will check to spread
		private var spreadCheck:int = 0;
		
		public function InternalFire(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, _hitMask:MovieClip) 
		{
			super(_cg, _mc_object, _hitMask);
			mc_object.gotoAndStop("fire");
			mc_object.x = _pos.x;
			mc_object.y = _pos.y;
			depth = mc_object.y;
			setSpread();
		}
		
		/**
		 * Set the next time in frames that the fire will check to spread
		 */
		private function setSpread():void
		{
			spreadCheck = System.SECOND * 10 + System.getRandInt(0, System.SECOND * 10);
		}
		
		override public function step():Boolean 
		{
			var i:int;
			
			// check for fire spreading
			if (--spreadCheck == 0)
			{
				var dirCheck:int = System.getRandInt(0, 360);
				var offsetBase:Number = 30;
				for (i = System.getRandInt(3, 6); i >= 0; i--)
				{
					if (Math.random() < .4)
						continue;
					
					var offset:Number = offsetBase *= System.getRandNum(.8, 1.6);
					var checkPoint:Point = new Point(mc_object.x + System.forward(offset, dirCheck, true), mc_object.y + System.forward(offset, dirCheck, false));
										
					if (isPointValid(checkPoint) && !cg.managerMap[System.M_FIRE].isNearOther(this, 30))
						cg.addToGame(new InternalFire(cg, new SWC_Decor(), checkPoint, hitMask), System.M_FIRE);
					
					dirCheck = (dirCheck + 40 + System.getRandInt(0, 30)) % 360;
				}
				setSpread();
			}
			
			// TODO damage nearby flammable things
			var player:Player;
			var dist:Number;
			for (i = 0; i < cg.players.length; i++)
			{
				player = cg.players[i];
				dist = System.getDistance(mc_object.x, mc_object.y, player.mc_object.x, player.mc_object.y);
				if (dist < FIRE_RANGE)
					continue;
				player.changeHP(FIRE_DAMAGE * (1 - (dist / FIRE_RANGE)));
			}
			
			return super.step();
		}
	}
}