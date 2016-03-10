package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * Helper that gets (and possibly does stuff with) the closest item within range of an object
	 * Objects managed should all be ABST_Consoles.
	 * @author Alexander Huynh
	 */
	public class ManagerProximity extends ABST_Manager 
	{
		
		public function ManagerProximity(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function step():void 
		{
			// -- shouldn't be called; do nothing
		}
		
		/**
		 * Should be called by the Player when it moves (or when it has just activated a console).
		 * 
		 */
		public function updateProximities(p:Player):void
		{
			var c:ABST_Console;
			
			// don't check proximity for this player if they are incapacitated
			if (p.getHP() == 0)
			{
				for each (c in objArray)
					c.setProximity(null, 99999);
				return;
			}
			
			var closestDist:Number = 99999;
			var closestConsole:ABST_Console;
			var dist:Number;
			
			for each (c in objArray)
			{
				if (c.inUse)				// skip things already being used
					continue;
				dist = c.getDistance(p);
				if (dist > c.RANGE)			// skip things out of range
					continue;
				if (dist < closestDist)
				{
					closestDist = dist;
					closestConsole = c;
				}
			}
			
			for each (c in objArray)
				c.setProximity(c == closestConsole ? p : null, dist);
		}
	}
}