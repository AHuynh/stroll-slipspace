package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * The Eyeball enemy
	 * @author Alexander Huynh
	 */
	public class EnemyEyeball extends ABST_Enemy 
	{
		private var animationCooldown:int = 0;
		
		public function EnemyEyeball(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle("eye");
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
			if (!isActive()) return;
			mc_object.base.gotoAndStop(2);		// make the eye light up
			animationCooldown = 7;				// the eye will go back to normal after 7 frames
		}
		
		override public function destroy():void 
		{
			for (var i:int = 5 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_eye", {
											"x": System.getRandNum(mc_object.x - 25, mc_object.x + 25),
											"y": System.getRandNum(mc_object.y - 25, mc_object.y + 25),
											"dx": System.getRandNum( -1, 1),
											"dy": System.getRandNum( -1, 1),
											"dr": System.getRandNum( -5, 5),
											"rot": System.getRandNum(0, 360),
											"scale": System.getRandNum(1, 2),
											"alphaDelay": 90 + System.getRandInt(0, 30),
											"alphaDelta": 30,
											"random": true
										});
			super.destroy();
		}
	}
}