package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileAoE;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Turret variant that fires AoE shots
	 * @author Alexander Huynh
	 */
	public class ConsoleTurretAoE extends ConsoleTurret 
	{
		
		public function ConsoleTurretAoE(_cg:ContainerGame, _mc_object:MovieClip, _turret:MovieClip, _players:Array, _gimbalLimits:Array, _controlIDs:Array, _turretID:int, _ghost:Boolean=false) 
		{
			super(_cg, _mc_object, _turret, _players, _gimbalLimits, _controlIDs, _turretID, _ghost);
			TUT_TITLE = "AoE Turret Module";
			TUT_MSG = "A special, more powerful turret.\n\nExplodes into smaller bullets if it hits something or after a short delay."
			setLevel(0);
		}

		override public function setLevel(lvl:int):void
		{
			super.setLevel(lvl);
			switch (lvl)
			{
				case 0:
					sway = 2;
					cooldown = System.SECOND * 4;
					projectileSpeed = 9;
					projectileLife = int(System.SECOND * 1.5);
					leadAmt = 1.05;
					distAmt = .07;
				break;
				case 1:
					sway = 1;
					cooldown = int(System.SECOND * 3);
					projectileSpeed = 11;
					projectileLife = int(System.SECOND * 1.35);
					leadAmt = .9;
					distAmt = .07;
				break;
				case 2:
					sway = 0;
					cooldown = int(System.SECOND * 2);
					projectileSpeed = 15;
					projectileLife = int(System.SECOND * 1.2);
					leadAmt = .8;
					distAmt = .07;
				break;
			}
		}
		
		override protected function fire():void
		{
			cdCount = cooldown;
			cg.addToGame(new EProjectileAoE(cg, new SWC_Bullet(),
													{	 
														"affiliation":	System.AFFIL_PLAYER,
														"dir":			turret.nozzle.rotation + rotOff + System.getRandNum(-sway, sway),
														"dmg":			75,
														"life":			projectileLife,
														"hp":			8,
														"pdmg":			6,
														"pos":			turret.nozzle.spawn.localToGlobal(new Point(turret.nozzle.spawn.x, turret.nozzle.spawn.y)),
														"spd":			projectileSpeed,
														"style":		"turret_standard",
														"ghost":		true
													}), System.M_EPROJECTILE);
			SoundManager.playSFX("sfx_laser2", .6);
		}
	}
}