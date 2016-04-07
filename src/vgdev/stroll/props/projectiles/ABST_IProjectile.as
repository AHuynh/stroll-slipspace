package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.managers.ManagerEnemy;
	import vgdev.stroll.managers.ManagerProjectile;
	import vgdev.stroll.managers.ManagerGeneric;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Boarder;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * Base class for all projectiles inside of the ship
	 * @author Alexander Huynh
	 */
	public class ABST_IProjectile extends ABST_IMovable 
	{
		// polar
		protected var spd:Number;
		protected var dir:Number;

		/// Time in frames until this projectile kills itself
		protected var life:int;
		
		/// Base amount of damage to deal
		protected var dmg:Number;
		
		protected var attackColor:uint;
		protected var colorTrans:ColorTransform;
		
		protected var managerProj:ManagerProjectile;
		protected var managerEnem:ManagerGeneric;
		protected var managerPlay:ManagerGeneric;
		protected var managerConsole:ManagerGeneric;
												
		public function ABST_IProjectile(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask);
			
			mc_object.x = attributes["pos"].x;
			mc_object.y = attributes["pos"].y;
			
			attackColor = System.setAttribute("attackColor", attributes, System.COL_WHITE);
			affiliation = System.setAttribute("affiliation", attributes, System.AFFIL_ENEMY)
			dir = System.setAttribute("dir", attributes, attributes);
			dmg = System.setAttribute("dmg", attributes, 6.0);
			life = System.setAttribute("life", attributes, 120);
			spd = System.setAttribute("spd", attributes, 2);
			setScale(System.setAttribute("scale", attributes, 1));
			
			managerProj = cg.managerMap[System.M_IPROJECTILE];
			managerEnem = cg.managerMap[System.M_BOARDER];
			managerPlay = cg.managerMap[System.M_PLAYER];
			managerConsole = cg.managerMap[System.M_CONSOLE];
			
			mc_object.rotation = dir;
			
			// display the correct graphic
			mc_object.gotoAndStop(System.setAttribute("style", attributes, 1));
			
			// tint the graphic
			if (attackColor != 0)
			{
				colorTrans = new ColorTransform();
				colorTrans.color = attackColor;
				mc_object.transform.colorTransform = colorTrans;
			}
		}
		
		override public function step():Boolean
		{
			if (--life <= 0)
				destroy();
			else
			{
				updatePosition(System.forward(spd, dir, true), System.forward(spd, dir, false));	
				updateCollisions();
			}
			return completed;
		}
		
		override protected function onShipHit():void 
		{
			destroy();
		}
		
		/**
		 * Do things based on if this projectile has hit other objects
		 */
		protected function updateCollisions():void
		{
			if (getAffiliation() == System.AFFIL_ENEMY)			// projectile collision with player or console
			{
				var hitObj:ABST_Object = managerPlay.collideWithOther(this, true);
				if (hitObj != null)
				{
					hitObj.changeHP( -dmg);
					destroy();
					return;
				}
				hitObj = managerConsole.collideWithOther(this, true);
				if (hitObj != null)
				{
					hitObj.changeHP( -dmg * 10);		// bonus damage VS consoles
					destroy();
				}
			}
			else if (getAffiliation() == System.AFFIL_PLAYER)	// projectile is a player's; check for hits on enemies
			{
				var hitEnemy:ABST_Boarder = managerEnem.collideWithOther(this, true) as ABST_Boarder;		// check for any hit
				if (hitEnemy != null)
				{
					(hitEnemy as ABST_Boarder).changeHP(-dmg);
					destroy();
				}
			}
		}
	}
}