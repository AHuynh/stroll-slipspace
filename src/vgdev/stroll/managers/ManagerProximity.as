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
			if (!objArray) return;
			for each (var c:ABST_Console in objArray)
				c.setProximity(p);
		}
	}
}