package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.Decor;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * A (single) fire on-board the ship
	 * @author Alexander Huynh
	 */
	public class InternalFire extends ABST_IMovable 
	{
		/// Minimum pixel distance to an object to apply damage
		private var FIRE_RANGE:int = 40;
		
		/// Maximum amount of HP damage to apply per tick; scales off of distance
		private var FIRE_DAMAGE:Number = -2;
		
		/// Amount of hull damage to apply
		private var HULL_DAMAGE:Number = .6;
		
		/// Frames until the fire will check to spread
		private var spreadCheck:int = 0;
		
		/// If false, has a chance to damage hull per tick. Changes to false on the first spread check.
		private var contained:Boolean = true;
		
		public function InternalFire(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, _hitMask:MovieClip) 
		{
			super(_cg, _mc_object, _hitMask);
			mc_object.gotoAndStop("fire");
			mc_object.x = _pos.x;
			mc_object.y = _pos.y;
			
			depth = mc_object.y;
			setSpread();
			
			hp = System.getRandInt(40, 60);		// don't start at full strength
			hpMax = 100;
			
			mc_object.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, init);
			if (!isPointValid(new Point(mc_object.x, mc_object.y)) || cg.isDefeatedPaused)
			{
				destroySilently();
				return;
			}
		}
		
		/**
		 * Set the next time in frames that the fire will check to spread
		 */
		private function setSpread():void
		{
			spreadCheck = System.SECOND * 7 + System.getRandInt(0, System.SECOND * 5);
		}
		
		// if being extinguished, delay the spread check
		override public function changeHP(amt:Number):Boolean 
		{
			if (amt < 0)
				spreadCheck += System.getRandInt(0, 3);
			return super.changeHP(amt);
		}
		
		override public function step():Boolean 
		{
			if (!isActive())
				return super.step();
				
			setScale(.5 + .5 * (hp / hpMax));
			mc_object.alpha = .75 + .25 * (hp / hpMax);	
			
			var i:int;
			
			// check for fire spreading
			if (--spreadCheck == 0)
			{
				var dirCheck:int = System.getRandInt(0, 360);		// pick a random polar rotation
				var offsetBase:Number = 30;							// distance away from the fire to check
				// check random spawn locations in a circle around the fire
				for (i = System.getRandInt(3, 6); i >= 0; i--)
				{
					if (Math.random() < .4)		// 40% chance to outright fail to spawn a new fire
						continue;
					
					var offset:Number = offsetBase *= System.getRandNum(.8, 1.6);		// slightly randomize the offset distance
					var checkPoint:Point = new Point(mc_object.x + System.forward(offset, dirCheck, true), mc_object.y + System.forward(offset, dirCheck, false));
										
					// create a new fire if the spawn location is not colliding with the ship and the fire is far enough away from other fires
					if (isPointValid(checkPoint) && !cg.managerMap[System.M_FIRE].isNearOther(this, 30))
						cg.addToGame(new InternalFire(cg, new SWC_Decor(), checkPoint, hitMask), System.M_FIRE);
					
					dirCheck = (dirCheck + 40 + System.getRandInt(0, 30)) % 360;
				}
				contained = false;		// this fire will now have a chance to deal hull damage
				setSpread();			// remember to check to see if this fire can spread again
			}

			// slowly restore HP (fire should return to full strength if not being actively extinguished)
			changeHP(.25);

			// damage things
			for (i = 0; i < cg.players.length; i++)
				damageObject(cg.players[i]);
			for (i = 0; i < cg.consoles.length; i++)
				damageObject(cg.consoles[i]);
			
			// after first spread check, 10% chance to damage hull per tick
			if (!contained && Math.random() < .1)
				cg.ship.damageDirect(HULL_DAMAGE, true);
							
			return super.step();
		}
		
		/**
		 * Deal scaled damage (based on FIRE_RANGE, FIRE_DAMAGE, and extinguish state) to an object if it is within range
		 * @param	obj		The object to damage
		 */
		private function damageObject(obj:ABST_Object):void
		{
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, obj.mc_object.x, obj.mc_object.y);
			if (dist <= FIRE_RANGE)
				obj.changeHP(FIRE_DAMAGE * (.5 + .5 * (hp / hpMax)) * (1 - (dist / FIRE_RANGE)));
		}
	}
}