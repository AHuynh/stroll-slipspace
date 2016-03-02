package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * The Eyeball enemy
	 * @author Alexander Huynh
	 */
	public class EnemyEyeball extends ABST_Enemy 
	{
		private var animationCooldown:int = 0;
		
		public function EnemyEyeball(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, attributes:Object) 
		{
			super(_cg, _mc_object, _pos, attributes);
			mc_object.gotoAndStop("eye");
		}
		
		// animate the eye
		override public function step():Boolean 
		{
			if (isActive() && animationCooldown > 0)
				if (--animationCooldown == 0)
					mc_object.base.gotoAndStop(1);
			return super.step();
		}
		
		override protected function onFire():void 
		{
			animationCooldown = 7;
			mc_object.base.gotoAndStop(2);
		}
	}
}