package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.System;
	
	/**
	 * Undefeatable enemy that warns a color, then swipes at the ship.
	 * @author Alexander Huynh
	 */
	public class EnemySwipe extends ABST_Enemy 
	{
		private var atkDir:int;
		private var isUpOrDown:Boolean = false;
		private var locX:Number = 0;
		private var locY:Number = 0;
		
		public function EnemySwipe(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("swipe");
			mc_object.base.stop();
			mc_object.visible = false;
			
			cooldowns = [300];
			cdCounts = [300];
		}
		
		override public function step():Boolean 
		{
			if (!completed)
			{
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateWeapons();
				updateSwipePosition();		
			}
			return completed;
		}
		
		// invincible
		override public function changeHP(amt:Number):Boolean 
		{
			return false;
		}
		
		// attack animation takes 14 frames, with the 'hit' on frame 9
		override protected function updateWeapons():void 
		{
			cdCounts[0]--;
			switch (cdCounts[0])
			{
				case 145:		// choose color and attack direction, spawn color warning
					setBaseColor(System.getRandCol());
					attackColor = selfColor;
					atkDir = System.getRandInt(0, 3);
					switch (atkDir)
					{
						case 0:		// right
							locX = 1;
							locY = System.getRandNum( -System.GAME_HEIGHT * .2, System.GAME_HEIGHT * .2);
							mc_object.rotation = 90;
							isUpOrDown = false;
						break;
						case 1:		// up
							locX = System.getRandNum(-System.GAME_WIDTH * .3, System.GAME_WIDTH * .3);
							locY = -1;
							mc_object.rotation = 0;
							isUpOrDown = true;
						break;
						case 2:		// left
							locX = -1;
							locY = System.getRandNum(-System.GAME_HEIGHT * .2, System.GAME_HEIGHT * .2);
							mc_object.rotation = 270;
							isUpOrDown = false;
						break;
						case 3:		// down
							locX = System.getRandNum(-System.GAME_WIDTH * .2, System.GAME_WIDTH * .2);
							locY = 1;
							mc_object.rotation = 180;
							isUpOrDown = true;
						break;
					}
					spawnTelegraphs();
				break;
				case 14:		// play attack animation
					mc_object.visible = true;
					mc_object.base.play();
				break;
				case 9:			// deal damage
					cg.ship.damage(attackStrength, attackColor, .1);	// correct shields will block 90% of damage
				break;
				case 0:			// reset
					cdCounts[0] = int(cooldowns[0] * System.getRandNum(1, 1.2));
					mc_object.visible = false;
				break;
			}
		}
		
		// since it can't be defeated, it doesn't jam
		override public function getJammingValue():int 
		{
			return 0;
		}
		
		// it doesn't move
		override public function getDelta():Point 
		{
			return new Point();
		}
		
		// keep the hand positioned relative to the camera
		// TODO fix
		private function updateSwipePosition():void
		{
			if (cdCounts[0] > 14) return;
			mc_object.x = !isUpOrDown ? cg.camera.getFocusLoc(true) + System.GAME_HALF_WIDTH * locX : locX;
			mc_object.y = isUpOrDown ? cg.camera.getFocusLoc(false) + System.GAME_HALF_HEIGHT * locY : locY;
		}
		
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			// will never 'move' in the traditional sense
			return;
		}
		
		// spawn a shower of decor objects colored to match the impending attack
		private function spawnTelegraphs():void
		{
			for (var i:int = 12 + System.getRandInt(0, 5); i >= 0; i--)
			{
				cg.addDecor("swipeTelegraph", {
											"x": isUpOrDown ? System.getRandNum(-System.GAME_WIDTH * .3, System.GAME_WIDTH * .3) * locY : (System.GAME_WIDTH) * (locX > 0 ? 1 : -1),
											"y": !isUpOrDown ? System.getRandNum(-System.GAME_HEIGHT * .2, System.GAME_HEIGHT * .2) * locX : (System.GAME_HEIGHT) * (locY > 0 ? 1 : -1),
											"dx": isUpOrDown ? System.getRandNum( -4, 4) : System.getRandNum(9, 15) * -locX,
											"dy": !isUpOrDown ? System.getRandNum( -4, 4) : System.getRandNum(9, 15) * -locY,
											"dr": System.getRandNum( -5, 5),
											"rot": System.getRandNum(0, 360),
											"alphaDelay": 90 + System.getRandInt(0, 30),
											"alphaDelta": 15,
											"tint": selfColor,
											"style": "swipeTelegraph"
										});
			}
		}
	}
}