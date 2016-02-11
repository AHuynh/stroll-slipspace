package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;

	/**
	 * Abstract Manager class, for managing mulitple instances of related objects
	 * @author Alexander Huynh
	 */
	public class ABST_Manager 
	{
		protected var cg:ContainerGame;
		
		/// An array of ABST_Objects
		protected var objArray:Array;
		
		public function ABST_Manager(_cg:ContainerGame) 
		{
			cg = _cg;
			objArray = [];
		}
		
		/**
		 * Called once per frame by ContainerGame
		 */
		public function step():void
		{
			// -- override this function
			for (var i:int = objArray.length - 1; i >= 0; i--)
				if (objArray[i].step())
					objArray.splice(i, 1);
		}
		
		public function setObjects(objs:Array):void
		{
			for (var i:int = objArray.length - 1; i >= 0; i--)
				objArray[i].kill();
			objArray = objs;
		}
		
		public function addObject(obj:*):void
		{
			objArray.push(obj);
		}
		
		/**
		 * Clean-up function
		 */
		public function destroy():void
		{
			// -- override this function
			for (var i:int = objArray.length - 1; i >= 0; i--)
				objArray[i].kill();
			objArray = null;
			cg = null;
		}
	}
}