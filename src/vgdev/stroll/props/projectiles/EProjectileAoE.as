package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import flash.geom.Point;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Explodes into AoE on death
	 * @author Alexander Huynh
	 */
	public class EProjectileAoE extends EProjectileHardened 
	{		
		public function EProjectileAoE(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
		}
		
		override public function destroySilently():void 
		{
			markedToKill = false;
			hp = life = 0;
			super.destroy();
		}
		
		override public function destroy():void
		{
			if (completed) return;
			if (life == 0 || (!markedToKill && hp == 0))
			{
				markedToKill = true;
				hp = 0;
				life = -1;
				var proj:EProjectileGeneric;
				for (var n:int = 0; n < 16; n++)
				{
					proj = new EProjectileGeneric(cg, new SWC_Bullet(),
														{	 
															"affiliation":	System.AFFIL_PLAYER,
															"dir":			n * 22.5,
															"dmg":			5,
															"life":			30,
															"pos":			mc_object.localToGlobal(new Point()),
															"spd":			10,
															"scale":		0.5,
															"style":		"turret_small"
														});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
				SoundManager.playSFX("sfx_laser3");
				super.destroy();
			}
			else
				damage(1);
		}
	}
}