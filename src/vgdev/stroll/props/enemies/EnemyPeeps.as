package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Sector 4 boss. Main body.
	 * @author Alexander Huynh
	 */
	public class EnemyPeeps extends ABST_Enemy 
	{
		private var eyes:Array = [null, null];			// reference to the 2 EnemyPeepsEyes
		private var hitbox_alternate:MovieClip = null;	// hitbox for the eye itself only (not the rest of the body)
		
		// TODO invincibility unless vulnerable
		// TODO counter to determine when to open the 2 smaller eyes
		// TODO counter to determine how long Peeps is vulnerable
		// TODO counter to determine when Peeps can teleport
		// TODO sub-counter to help Peeps multi-teleport in Phase 3
		// TODO keep track of what phase (1, 2, 3) Peeps is in
		
		
		// ---- GRAPHICS MANIPULATION ------------------------------------------------------------------------
		//mc_object.base.gotoAndStop("closed");		// display Peeps with his main eye closed (default state, a large red X will appear to show the eye is closed)
		//mc_object.base.gotoAndStop("open");		// display Peeps with his main eye open
		
		
		public function EnemyPeeps(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, {});
			setStyle("peeps");
			
			// TODO initialize things like x, y, hp, etc. (passed in attributes:Object will have nothing useful)
			mc_object.x = 400;	// (temporary values)
			mc_object.y = 0;
			hp = hpMax = 30;
			
			// TODO create 2 instances of EnemyPeepsEye
			//new EnemyPeepsEye(cg, new SWC_Enemy(), this);
			
			// [hardened shot, triple shot]
			cdCounts = [90, 90];		// initial cooldown value (TODO balance)
			cooldowns = [120, 140];		// cooldown value (TODO balance)
		}
		
		// hide both hitboxes
		override protected function setStyle(style:String):void 
		{
			super.setStyle(style);
			hitbox_alternate = mc_object.hitbox_alternate;
			mc_object.hitbox.visible = hitbox_alternate.visible = false;
		}
		
		// TODO modify as needed
		override protected function updatePosition(dx:Number, dy:Number):void
		{
			if (completed)
				return;
			
			var ptNew:Point = new Point(mc_object.x + dx, mc_object.y + dy);
			if (isPointValid(ptNew))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
				
				// (code deleted here - don't kill if Peeps is out of bounds)
			}
			else	// ship was hit
			{
				if (affiliation != System.AFFIL_PLAYER)
					onShipHit();
				// (code deleted here - don't kill if Peeps is out of bounds)
			}
		}
		
		override protected function updateWeapons():void 
		{
			// TODO override (see EnemySquid.as for example of HardenedShot and triple shot)
		}
		
		// TODO function to spawn add(s) (EnemyEyeball) where Peeps originally was when teleporting
		// TODO when vulnerable, only take damage if the alternate hitbox was hit		(maybe, might require another class like EnemyPeepsMainEye and be too much hassle)
	}
}