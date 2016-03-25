package vgdev.stroll.support 
{
	import vgdev.stroll.ContainerGame;
	/**
	 * Abstract support class
	 * @author Alexander Huynh
	 */
	public class ABST_Support 
	{
		protected var cg:ContainerGame;
		
		public function ABST_Support(_cg:ContainerGame)
		{
			cg = _cg;
		}
		
		public function step():void
		{
			// -- override this function
		}
		
		public function destroy():void
		{
			cg = null;
		}
	}
}