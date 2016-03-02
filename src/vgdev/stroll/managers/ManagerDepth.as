package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	
	/**
	 * Sorts objects in its array by y and updates their depths.
	 * @author Alexander Huynh
	 */
	public class ManagerDepth extends ABST_Manager 
	{
		public function ManagerDepth(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		public function updateDepths():void
		{
			objArray.sortOn("depth", Array.NUMERIC);
			for each (var obj:ABST_Object in objArray)
				cg.addChild(obj.mc_object);
		}
		
		// untrack items that are no longer active
		override public function step():void 
		{
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
			super.addObject(obj);
			updateDepths();
		}
	}
}