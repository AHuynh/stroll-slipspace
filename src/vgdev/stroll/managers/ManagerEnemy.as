package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	
	/**
	 * Manager for ABST_Enemy that takes into account jamming values
	 * @author Alexander Huynh
	 */
	public class ManagerEnemy extends ABST_Manager 
	{
		
		public function ManagerEnemy(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function numObjects():int 
		{
			var total:int = 0;
			for each (var enemy:ABST_Enemy in objArray)
				total += enemy.getJammingValue();
			return total;
		}
	}
}