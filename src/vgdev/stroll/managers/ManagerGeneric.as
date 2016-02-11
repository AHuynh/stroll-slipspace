package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Same as ABST_Manager (but not abstract)
	 * @author Alexander Huynh
	 */
	public class ManagerGeneric extends ABST_Manager 
	{
		public function ManagerGeneric(_cg:ContainerGame) 
		{
			super(_cg);
		}
	}
}