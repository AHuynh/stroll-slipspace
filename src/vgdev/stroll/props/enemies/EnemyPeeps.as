package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.props.projectiles.EProjectileHardened;
	
	/**
	 * Sector 4 boss. Main body.
	 * @author Jimmy Spearman, Alexander Huynh
	 */
	public class EnemyPeeps extends ABST_Enemy 
	{		
		private var eyes:Array = [null, null];			// reference to the 2 EnemyPeepsEyes
		private var eyeYOffsets:Array = [100, -100];
		private var eyeXOffsets:Array = [0, 0];
		private var hitbox_alternate:MovieClip = null;	// hitbox for the eye itself only (not the rest of the body)
		
		private var incapacitated:Boolean = false;
		private var recoverCooldownMax:Number = 130; //frames before recovering
		private var recoverCooldownTimer:Number = recoverCooldownMax; //current number for cooldown
		private var wasIncapacitated:Boolean = false;
		
		
		private var teleportCooldownMax:Number = 300; //frames before teleporting
		private var teleportCooldownTimer:Number = teleportCooldownMax; //current number for cooldown
		private var currentAreaNumber:int = 0;
		
		private var bossPhase:int = 1;
		private var prevBossPhase:int = 1;
		private var phaseChangeImmune:Boolean = false;
		private var phaseChangeCooldownMax:Number = 130; //frames before battle resumes
		private var phaseChangeCooldownTimer:Number = phaseChangeCooldownMax; //current number for cooldown
		
		
		
		
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

			hp = hpMax = 500;
			ranges = [290, 400];
			
			
			eyes[0] = new EnemyPeepsEye(cg, new SWC_Enemy(), this);
			eyes[1] = new EnemyPeepsEye(cg, new SWC_Enemy(), this);
			// [hardened shot, triple shot]
			cdCounts = [300];		// initial cooldown value (TODO balance)
			cooldowns = [400];		// cooldown value (TODO balance)
		}
		
		// hide both hitboxes
		override protected function setStyle(style:String):void 
		{
			super.setStyle(style);
			hitbox_alternate = mc_object.hitbox_alternate;
			mc_object.hitbox.visible = hitbox_alternate.visible = false;
		}
		
		//Spawn eyes when peeps is spawned
		override public function spawnActions():void 
		{
			
			for (var i:int = 0; i < eyes.length; i++) {
				cg.addToGame(eyes[i], System.M_ENEMY);
				eyes[i].mc_object.x = mc_object.x;
				eyes[i].mc_object.y = mc_object.y + eyeYOffsets[i];
			}
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
			if (incapacitated) {
				return;
			}
			
			
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				var proj:ABST_EProjectile;
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					proj = new EProjectileHardened(cg, new SWC_Bullet(),
																		{	 
																			"affiliation":	System.AFFIL_ENEMY,
																			"attackColor":	attackColor,
																			"dir":			System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) + System.getRandNum( -10, 10),
																			"rot":			90 * System.getRandInt(0, 3),
																			"dmg":			2*attackStrength,
																			"hp":			4,
																			"life":			500,
																			"pdmg":			3,
																			"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																			"spd":			0.5,
																			"style":		"pus",
																			"scale":		2
																		});
							cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
		}
		
		override public function step():Boolean 
		{
			if (mc_object == null) {
				return true;
			}
			
			if (eyes[0].isIncapacitated() && eyes[1].isIncapacitated()) {
				if (!incapacitated) {
					SoundManager.playSFX("sfx_peeps_yell", 1);
					incapacitated = true;
				}
			} 
			
			if (incapacitated) {
				recoverCooldownTimer--;
				if (recoverCooldownTimer <= 0) {
					revivePeeps();
				} else {
					updatePosition(5*Math.cos(4*cg.level.getCounter()), 0);
				}
				
			} else {
				teleportCooldownTimer--;
				if (teleportCooldownTimer < 0) {
					randomTeleport();
					teleportCooldownTimer = teleportCooldownMax;
				}
			}
			
			checkPhase();
			
			lockEyes();
		
			return super.step();
		}
		
		private function checkPhase():void
		{
			if (hp > (hpMax * 2.0 / 3.0)) {
				bossPhase = 1;
			} else if (hp > (hpMax / 3.0)) {
				bossPhase = 2;
			} else {
				bossPhase = 3;
			}
			
			if (bossPhase != prevBossPhase) {
				initiatePhaseChange();
			}
			
			if (phaseChangeImmune) {
				updatePosition(5 * Math.cos(4.43 * cg.level.getCounter()), 5 * Math.cos(2 * cg.level.getCounter()));
				incapacitated = true;
				if (phaseChangeCooldownTimer-- < 0) {
					phaseChangeImmune = false;
					revivePeeps();
				}
			}
			
			prevBossPhase = bossPhase;
		}
		
		private function initiatePhaseChange():void {
			phaseChangeImmune = true;
			phaseChangeCooldownTimer = phaseChangeCooldownMax;
			SoundManager.playSFX("sfx_peeps_phase_change", 1);
		}
		
		private function lockEyes():void
		{
			for (var i:int = 0; i < eyes.length; i++) {
				eyes[i].mc_object.x = mc_object.x + eyeXOffsets[i];
				eyes[i].mc_object.y = mc_object.y + eyeYOffsets[i];
			}
		}
		
		private function moveEyeball(dx:Number, dy:Number, eyeNumber:int):void 
		{
			eyeXOffsets[eyeNumber] += dx;
			eyeYOffsets[eyeNumber] += dy;
		}
		
		private function revivePeeps():void
		{
			incapacitated = false;
			recoverCooldownTimer = recoverCooldownMax;
			
			for (var i:int = 0; i < eyes.length; i++) {
				eyes[i].reviveEye();
			}
		}
		
		override public function changeHP(amt:Number):Boolean 
		{	
			return super.changeHP( -99999);
			if (incapacitated && !phaseChangeImmune) {
				return super.changeHP(amt);
			} else {
				return false;
			}
			
		}
		
		//teleport peeps to a new location around the ship
		private function randomTeleport():void
		{
			var areaChange:int = System.getRandInt(1, 4);
			
			currentAreaNumber = (currentAreaNumber + areaChange) % 5;
			
			if (bossPhase > 1) {
				var newSpawn:ABST_Enemy = new EnemyEyeball(cg, new SWC_Enemy(), {});
				newSpawn.mc_object.x = mc_object.x;
				newSpawn.mc_object.y = mc_object.y;
				cg.addToGame(newSpawn, System.M_ENEMY);
			}
			

			if (currentAreaNumber == 0) {
				mc_object.x = 350;
				mc_object.y = 0;
				
				eyeXOffsets = [0, 0];
				eyeYOffsets = [100, -100];
			} else if (currentAreaNumber == 1) {
				mc_object.x = 0;
				mc_object.y = 230;
				
				eyeXOffsets = [100, -100];
				eyeYOffsets = [0, 0];
			} else if (currentAreaNumber == 2) {
				mc_object.x = -350;
				mc_object.y = 230;
				
				eyeXOffsets = [70.7, -70.7];
				eyeYOffsets = [70.7, -70.7];
			} else if (currentAreaNumber == 3) {
				mc_object.x = -350;
				mc_object.y = -230;
				
				eyeXOffsets = [-70.7, 70.7];
				eyeYOffsets = [70.7, -70.7];
			} else {
				mc_object.x = 0;
				mc_object.y = -230;
				
				eyeXOffsets = [-100, 100];
				eyeYOffsets = [0, 0];
			}
			
			
		}
		
		override public function destroy():void 
		{
			for (var i:int = 0; i < eyes.length; i++) {
				eyes[i].kill();
			}
			SoundManager.playBGM("bgm_calm", System.VOL_BGM);
			super.destroy();
		}
		
		public function isIncapacitated():Boolean
		{
			return incapacitated;
		}
		
		
		
		// TODO when vulnerable, only take damage if the alternate hitbox was hit		(maybe, might require another class like EnemyPeepsMainEye and be too much hassle)
	}
}