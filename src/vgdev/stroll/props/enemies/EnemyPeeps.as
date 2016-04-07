package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
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
		private var eyes:Array = [];									// reference to the 4 EnemyPeepsEyes from L to R
		private var eyeXOffsets:Array = [71, 44, 44, 71];
		private var eyeYOffsets:Array = [ -152.5, -105.5, 108.5, 153.5];
		public var activeEyes:Array = [0, 0];
		
		private var incapacitated:Boolean = false;
		private var recoverCooldownMax:Number = 130; 					//frames before recovering
		private var recoverCooldownTimer:Number = recoverCooldownMax;	//current number for cooldown
		private var wasIncapacitated:Boolean = false;
		
		private var teleportCooldownMax:Number = 4200000000; 					//frames before teleporting
		private var teleportCooldownTimer:Number = teleportCooldownMax; //current number for cooldown
		private var currentAreaNumber:int = 0;
		
		private var bossPhase:int = 1;
		private var prevBossPhase:int = 1;
		private var phaseChangeImmune:Boolean = false;
		private var phaseChangeCooldownMax:Number = 130;					  //frames before battle resumes
		private var phaseChangeCooldownTimer:Number = phaseChangeCooldownMax; //current number for cooldown

		public function EnemyPeeps(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, {"noSpawnFX": true});
			setStyle("peeps");
			
			mc_object.hitbox.visible = false;
			hitbox = mc_object.hitbox;
			
			mc_object.visible = false;
			mc_object.x = 400;
			mc_object.y = 0;
			
			orbitX = System.ORBIT_0_X + 50;
			orbitY = System.ORBIT_0_Y + 60;

			hp = hpMax = 500;
			rangeVary = 20;
			
			for (var i:int = 0; i < 4; i++)
				eyes.push(new EnemyPeepsEye(cg, new SWC_Enemy(), this));
			lockEyes();
			// [hardened shot, triple shot]
			cdCounts = [300];		// initial cooldown value
			cooldowns = [400];		// cooldown value
						
			mc_object.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, init);
			mc_object.visible = true;
			for (var i:int = 0; i < 4; i++)
				cg.addToGame(eyes[i], System.M_ENEMY);
			setNewEyes();
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "rot": System.getRandNum(0, 360), "scale": 6} );
			spawnFX.mc_object.base.setTint(System.COL_RED);
		}
		
		private function setNewEyes():void
		{
			for (var i:int = 0; i < 4; i++)
				eyes[i].mc_object.base.gotoAndStop(1);		// close eyelid
			activeEyes[0] = System.getRandInt(0, 1);
			activeEyes[1] = System.getRandInt(2, 3);
		}
		
		override protected function updatePosition(dx:Number, dy:Number):void
		{
			if (completed)
				return;
			
			var ptNew:Point = new Point(mc_object.x + dx, mc_object.y + dy);
			if (isPointValid(ptNew))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
				
				for (var i:int = 0; i < eyes.length; i++)
					eyes[i].updateEyePosition(dx, dy);
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
																			"style":		"eye",
																			"scale":		3
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
			
			//trace(activeEyes);
			//trace("\t", eyes[activeEyes[0]].isIncapacitated(), eyes[activeEyes[1]].isIncapacitated());
			if (eyes[activeEyes[0]].isIncapacitated() && eyes[activeEyes[1]].isIncapacitated()) {
				if (!incapacitated) {
					SoundManager.playSFX("sfx_peeps_yell", 1);
					incapacitated = true;
					mc_object.base.mc_lid_large.visible = false;
					for (var e:int = 0; e < 4; e++)
						eyes[e].mc_object.base.gotoAndStop(1);		// close eyelid
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
					teleportCooldownTimer = teleportCooldownMax + System.getRandInt(0, 90);
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
			var theta:Number = System.degToRad(mc_object.rotation);
			var s:Number = Math.sin(theta);
			var c:Number = Math.cos(theta);
			for (var i:int = 0; i < eyes.length; i++) {
				eyes[i].mc_object.x = mc_object.x + eyeXOffsets[i] * c - eyeYOffsets[i] * s;
				eyes[i].mc_object.y = mc_object.y + eyeXOffsets[i] * s + eyeYOffsets[i] * c;
				eyes[i].mc_object.rotation = mc_object.rotation;
			}
		}
		
		private function revivePeeps():void
		{
			incapacitated = false;
			recoverCooldownTimer = recoverCooldownMax;
			mc_object.base.mc_lid_large.visible = true;
			
			for (var i:int = 0; i < eyes.length; i++) {
				eyes[i].reviveEye();
			}
			setNewEyes();
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
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
			
			cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale": 4 } );
			
			if (bossPhase > 1) {
				var newSpawn:ABST_Enemy = new EnemyEyeball(cg, new SWC_Enemy(), {});
				newSpawn.mc_object.x = mc_object.x;
				newSpawn.mc_object.y = mc_object.y;
				cg.addToGame(newSpawn, System.M_ENEMY);
			}
			
			if (currentAreaNumber == 0) {
				mc_object.x = 350;
				mc_object.y = 0;
			} else if (currentAreaNumber == 1) {
				mc_object.x = 0;
				mc_object.y = 300;
			} else if (currentAreaNumber == 2) {
				mc_object.x = -350;
				mc_object.y = 230;
			} else if (currentAreaNumber == 3) {
				mc_object.x = -350;
				mc_object.y = -230;
			} else {
				mc_object.x = 0;
				mc_object.y = -300;
			}
			
			cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale": 4 } );
			
			setNewEyes();
			mc_object.rotation = 360 + System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y) % 360;
			lockEyes();
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
	}
}