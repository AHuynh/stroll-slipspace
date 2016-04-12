package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	
	/**
	 * Sector 4 boss. 1 of 4 extra eyes.
	 * @author Jimmy Spearman, Alexander Huynh
	 */
	public class EnemyPeepsEye extends ABST_Enemy 
	{
		public static var numEyes:Number = 0;
		public var eyeNo:Number = 0;
		
		private var incapacitated:Boolean = false;
		private var mainBody:EnemyPeeps;			// reference to the main body of the boss
		
		public function EnemyPeepsEye(_cg:ContainerGame, _mc_object:MovieClip, _mainBody:EnemyPeeps) 
		{
			super(_cg, _mc_object, {"noSpawnFX":true});
			setStyle("peeps_eye");
			mainBody = _mainBody;
			
			setHPmax(2);
			eyeNo = numEyes++;
			
			// [small shot]
			cdCounts = [90 + System.getRandInt(0, 40)];
			cooldowns = [90];
			
			playDeathSFX = false;
		}
		
		override public function destroy():void 
		{
			incapacitated = true;
		}
		
		public function kill():void
		{
			super.destroy();
		}
		
		override public function step():Boolean 
		{
			if (!completed)
			{
				updatePrevPosition();
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateWeapons();		
				updateDamageFlash();				
			}
			return completed;
		}
		
		public function reviveEye():void
		{
			incapacitated = false;
			hp = hpMax;	
		}
		
		/**
		 * Pulic accessor for updatePosition
		 * @param	dx
		 * @param	dy
		 */
		public function updateEyePosition(dx:Number, dy:Number):void
		{
			updatePosition(dx, dy);
		}
		
		/**
		 * Force the eyes to shoot next frame; synchs eyes to make it easier to shoot both simultaneously
		 */
		public function forceShoot():void
		{
			cdCounts[0] = 1;
		}
		
		public function getIsActive():Boolean
		{
			return mainBody.activeEyes[0] == eyeNo || mainBody.activeEyes[1] == eyeNo;
		}
		
		public function getIfMainIsIncapacitated():Boolean
		{
			return mainBody.isIncapacitated();
		}
		
		override protected function updateWeapons():void 
		{
			if (mainBody.isIncapacitated()) {
				return;
			}
			
			if (!getIsActive())
				return;
			
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cooldowns[i] = System.getRandInt(90, 110);		// allow stagger
					cdCounts[i] = cooldowns[i];
					var proj:ABST_EProjectile = new EProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation + System.getRandNum(-15, 15),
																		"dmg":			attackStrength,
																		"life":			150,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			6,
																		"style":		"eye",
																		"scale":		1
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
					mc_object.base.gotoAndStop(2);
				}
				else if (cdCounts[i] == cooldowns[i] - 50)
				{
					mc_object.base.gotoAndStop(1);
					reviveEye();
				}
			}
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			if (mc_object.base.currentFrame != 2)		// no damage if lid is closed
				return false;
			incapacitated = super.changeHP(amt);
			return incapacitated;
		}
		
		public function isIncapacitated():Boolean
		{
			return incapacitated;
		}		
		
		public function getEyeNo():int
		{
			return eyeNo;
		}
	}
}