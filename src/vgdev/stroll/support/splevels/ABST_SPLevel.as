package vgdev.stroll.support.splevels 
{
	import vgdev.stroll.ContainerGame;
	/**
	 * Provides functionality for a slipspace sector that requires code logic
	 * @author Alexander Huynh
	 */
	public class ABST_SPLevel 
	{
		protected var cg:ContainerGame;
		protected var framesElapsed:int = 0;
		
		public function ABST_SPLevel(_cg:ContainerGame) 
		{
			cg = _cg;
		}
		
		public function step():void
		{
			framesElapsed++;
			// -- override this function
		}
	}
}