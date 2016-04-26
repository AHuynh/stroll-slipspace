package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.WINGMAN;
	import vgdev.stroll.System;
	
	/**
	 * Controls the location and scale of the view
	 * @author Alexander Huynh
	 */
	public class Cam extends ABST_Support
	{
		private var ui:MovieClip;
		
		private var focus:Point;
		private var scale:Number = 1;
		
		public var focusTgt:Point;
		private const DEFAULT_TGT:Point = new Point();
		
		private var aiTgt:Point;
		private const THRESH_AI:Number = 100;
		
		private const ADD_SCALE:Array = [-.05, .05];
		private const THRESH_TRANSLATE:Number = 5;
		
		private var camMoveRate:Number = 10;
		
		public var lim_x_min:Number = -System.GAME_HALF_WIDTH / 2.2;
		public var lim_x_max:Number = System.GAME_HALF_WIDTH / 1.8;
		public var lim_y_min:Number = -System.GAME_HALF_HEIGHT / 2;
		public var lim_y_max:Number = System.GAME_HALF_HEIGHT / 2.5;
		
		private var camShake:int = 0;
		private var UI_ANCHOR_X:Number;
		private var UI_ANCHOR_Y:Number;
		
		private var aiCooldown:int = 0;
		private const AI_COOLDOWN:int = 20;
		
		public function Cam(_cg:ContainerGame, _ui:MovieClip)
		{
			super(_cg);
			ui = _ui;
			
			// custom stats
			if (cg.shipName == "Kingfisher")
				camMoveRate = 5;
			if (cg.engine.isAllAI())
				camMoveRate = 7;
			
			UI_ANCHOR_X = ui.x;
			UI_ANCHOR_Y = ui.y;
			
			focus = new Point(cg.game.x, cg.game.y);
			focusTgt = new Point(cg.game.x, cg.game.y);
		}
		
		override public function step():void
		{			
			// if 2 AI's, put cam between the 2 AI's targets and the ship center
			if (cg && cg.engine && cg.engine.isAllAI() && cg.players[0] && cg.players[1])
			{
				if (cg.useAutoCam)
				{
					if (aiCooldown++ >= AI_COOLDOWN)
					{
						aiCooldown = 0;
						aiTgt = new Point(System.calculateAverage([0, 0, (cg.players[0] as WINGMAN).tgtIndicator.x, (cg.players[1] as WINGMAN).tgtIndicator.x]),
										  System.calculateAverage([0, 0, (cg.players[0] as WINGMAN).tgtIndicator.y, (cg.players[1] as WINGMAN).tgtIndicator.y]));
						if (System.getDistance(-aiTgt.x, -aiTgt.y, focusTgt.x, focusTgt.y) > THRESH_AI)
							focusTgt = new Point( System.setWithinLimits(-aiTgt.x, lim_x_min, lim_x_max), 
												  System.setWithinLimits(-aiTgt.y, lim_y_min, lim_y_max));
					}
				}
				else
					focusTgt = DEFAULT_TGT;
			}
			
			focus.x = updateNumber(focus.x, focusTgt.x, [-camMoveRate, camMoveRate], THRESH_TRANSLATE);
			focus.y = updateNumber(focus.y, focusTgt.y, [-camMoveRate, camMoveRate], THRESH_TRANSLATE);

			cg.game.x = focus.x;
			cg.game.y = focus.y;
			
			cg.background.setLocation(new Point(cg.game.x / 4, cg.game.y / 4));

			System.GAME_OFFSX = cg.game.x + System.GAME_HALF_WIDTH;
			System.GAME_OFFSY = cg.game.y + System.GAME_HALF_HEIGHT;
			
			updateShake();
		}
		
		/**
		 * Start shaking the camera
		 * @param	frames		The amount of frames to shake
		 */
		public function setShake(frames:int):void
		{
			camShake = Math.max(camShake, frames);
			cg.setModuleColor(System.COL_REDHIT);
		}
		
		/**
		 * Shake the camera, or reset it back to normal if done
		 */
		private function updateShake():void
		{
			if (camShake > 0)
			{
				if (--camShake == 0)
				{
					ui.x = UI_ANCHOR_X;
					ui.y = UI_ANCHOR_Y;
					cg.setModuleColor(System.COL_WHITE);
				}
				else if (camShake % 2 == 1)
				{
					ui.x = System.getRandNum( -4, 4);
					ui.y = System.getRandNum( 0, 6);
				}
			}
		}
		
		public function isAtLimit(limIndex:int):Boolean
		{
			switch (limIndex)
			{
				case 0:	return lim_x_min == focus.x;
				case 1:	return lim_x_max == focus.x;
				case 2:	return lim_y_min == focus.y;
				case 3:	return lim_y_max == focus.y;
			}
			return false;
		}
		
		public function getFocusLoc(isX:Boolean):Number
		{
			return isX ? focus.x : focus.y;
		}
		
		private function updateNumber(num:Number, tgt:Number, add:Array, thresh:Number):Number
		{
			if (num == tgt)
				return num;
			num += add[num < tgt ? 1 : 0];
			if (Math.abs(num - tgt) < thresh)
				num = tgt;
				
			return num;
		}
		
		/**
		 * Set the camera's translation
		 * @param	newFocus	Point, where (0, 0) is the center of the screen
		 */
		public function setCameraFocus(newFocus:Point):void
		{
			focusTgt = new Point( -newFocus.x, -newFocus.y);
		}
		
		/**
		 * Move the camera's translation relative to its current position at a rate of camMoveRate per frame
		 * @param	offFocus	Point of scales to multiply camMoveRate by, where (0, 0) is no movement
		 */
		public function moveCameraFocus(offFocus:Point):void
		{
			focusTgt.x = System.changeWithLimit(focusTgt.x, offFocus.x * camMoveRate, lim_x_min, lim_x_max);
			focusTgt.y = System.changeWithLimit(focusTgt.y, offFocus.y * camMoveRate, lim_y_min, lim_y_max);
		}
		
		override public function destroy():void 
		{
			ui = null;
			super.destroy();
		}
	}
}