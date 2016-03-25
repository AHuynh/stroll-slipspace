package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.System;
	
	/**
	 * Sorts objects in its array by y and updates their depths.
	 * Depth-managed objects should reside in cg.game.mc_ship only.
	 * @author Alexander Huynh
	 */
	public class ManagerDepth extends ABST_Manager 
	{		
		public function ManagerDepth(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		/**
		 * Reorder all depth-managed objects based on their y positions
		 */
		public function updateDepths():void
		{
			if (!cg.game || !objArray) return;	
			objArray.sortOn("depth", Array.NUMERIC);
			for each (var obj:ABST_Object in objArray)
				if (obj.mc_object != null)
					cg.game.mc_ship.addChild(obj.mc_object);
		}

		// untrack items that are no longer active
		override public function step():void 
		{
			if (!objArray) return;
			var shouldUpdate:Boolean = false;
			for (var i:int = objArray.length - 1; i >= 0; i--)
				if (!objArray[i].isActive())
				{
					objArray.splice(i, 1);
					shouldUpdate = true;
				}
			if (shouldUpdate)
				updateDepths();
		}
		
		override public function addObject(obj:ABST_Object):void 
		{
			if (!objArray) return;
			super.addObject(obj);
			updateDepths();
		}
	}
}