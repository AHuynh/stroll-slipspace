package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	
	/**
	 * Sector 4 boss. 1 of 2 extra eyes.
	 * @author Alexander Huynh
	 */
	public class EnemyPeepsEye extends ABST_Enemy 
	{
		public static var numEyes:Number = 0;
		
		public var eyeNo:Number = 0;
		
		private var incapacitated:Boolean = false;
		private var recoverCooldownMax:Number = 60; //frames before recovering
		private var recoverCooldownTimer:Number = recoverCooldownMax; //current number 
		public var stopped:Boolean = false;
		private var mainBody:EnemyPeeps;		// reference to the main body of the boss
		private var maxHP:Number = 30;
		// TODO invincibility when eyes are closed
		
		public function EnemyPeepsEye(_cg:ContainerGame, _mc_object:MovieClip, _mainBody:EnemyPeeps) 
		{
			super(_cg, _mc_object, {});
			setStyle("peeps_eye");
			mainBody = _mainBody;
			
			hp = maxHP;
			
			eyeNo = numEyes++;
			
			// TODO initialize things like x, y, hp, etc. (there is no attributes object)
			
			// [small shot]
			cdCounts = [90 + System.getRandInt(0, 40)];		// initial cooldown value (TODO balance)
			cooldowns = [90];		// cooldown value (TODO balance)
		}
		
		override public function destroy():void 
		{
			incapacitated = true;
		}
		
		public function kill():void {
			super.destroy();
		}
		
		override public function step():Boolean 
		{
			if (incapacitated) {
				recoverCooldownTimer--;
				if (recoverCooldownTimer <= 0) {
					reviveEye();
				}
				
			}
			
			return super.step();
		}
		
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			super.updatePosition(dx, dy);
		}
		
		public function updateEyePosition(dx:Number, dy:Number):void
		{
			updatePosition(dx, dy);
		}
		
		
		//mc_object.base.gotoAndStop("closed");		// display this Peeps eye with its eye closed (default state)
		//mc_object.base.gotoAndStop("open");		// display this Peeps eye with its eye closed
		
		public function reviveEye():void
		{
			incapacitated = false;
			recoverCooldownTimer = recoverCooldownMax;
			hp = maxHP;			
		}
		
		override protected function updateWeapons():void 
		{
			if (incapacitated || mainBody.isIncapacitated()) {
				return;
			}
			
			
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var proj:ABST_EProjectile = new EProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation + System.getRandNum(-5, 5),
																		"dmg":			attackStrength,
																		"life":			150,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			6,
																		"style":		"pus",
																		"scale":		0.5
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
		}
		
		public function isIncapacitated():Boolean
		{
			return incapacitated;
		}
		
		
	}
}