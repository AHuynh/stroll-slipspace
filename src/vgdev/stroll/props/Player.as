package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.managers.ManagerProximity;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.projectiles.ABST_IProjectile;
	import vgdev.stroll.props.projectiles.IProjectileGeneric;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Instance of the player
	 * @author Alexander Huynh
	 */
	public class Player extends ABST_IMovable
	{
		/// Pointer to the proximity manager, so this Player can tell the manager to update
		public var manProx:ManagerProximity;
		
		// keys for use in keysDown
		private const RIGHT:int = 0;
		private const UP:int = 1;
		private const LEFT:int = 2;
		private const DOWN:int = 3;
		private const ACTION:int = 10;
		private const CANCEL:int = 11;
		
		// stored Keyboard keycodes
		private var KEY_RIGHT:uint;
		private var KEY_UP:uint;
		private var KEY_LEFT:uint;
		private var KEY_DOWN:uint;
		private var KEY_ACTION:uint;
		private var KEY_CANCEL:uint;
		
		/// Map of key states
		private var keysDown:Object = { UP:false, LEFT:false, RIGHT:false, DOWN:false, TIME:false };
		
		/// Direction player last moved in (RULD, 0-3)
		public var facing:int = 0;
		
		/// Player 0 or 1
		public var playerID:int;
		
		/// Pixels per frame this unit can move at
		public var moveSpeed:Number = 4;
		
		/// If not null, the instance of ABST_Console this Player is currently paired with
		public var activeConsole:ABST_Console = null;
		
		/// If true, the console being used prevents player movement
		private var rooted:Boolean = false;
		
		// PWD variables
		private var countPDW:int = 0;			// current PDW status
		private var cooldownPDW:int = 5;		// cooldown time in frames between PDW shots
		private var damagePDW:int = 7;
		
		private var BAR_WIDTH:Number;			// small bar above player sprite width
		private var bigBar:MovieClip;			// long thin bar above the module screen
		
		// helpers for revive S.O.S. text
		private var reviveExpire:int = 0;
		private var reviveProgress:Number = 0;
		public var reviveCounter:int = 0;
		
		// animation helpers
		private var isMoving:Boolean = false;
		public var highFive:int = 0;
		
		public function Player(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _playerID:int, keyMap:Object)
		{
			super(_cg, _mc_object, _hitMask);
			playerID = _playerID;
			hp = hpMax = 100;
			
			KEY_RIGHT = keyMap["RIGHT"];
			KEY_UP = keyMap["UP"];
			KEY_DOWN = keyMap["DOWN"];
			KEY_LEFT = keyMap["LEFT"];
			KEY_ACTION = keyMap["ACTION"];
			KEY_CANCEL = keyMap["CANCEL"];
			
			mc_object.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Helper to init the keyboard listener
		 * 
		 * @param	e	the captured Event, unused
		 */
		private function onAddedToStage(e:Event):void
		{
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			cg.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			cg.stage.addEventListener(KeyboardEvent.KEY_UP, upKeyboard);
			
			mc_object.mc_bar.visible = false;		// hide the HP bar
			BAR_WIDTH = mc_object.mc_bar.bar.width;
			
			bigBar = cg.hudBars[playerID];
			
			mc_object.mc_omnitool.visible = false;
			mc_object.mc_sos.visible = false;
			mc_object.prompt.visible = false;
		}
		
		/**
		 * Update the player
		 * @return		false; player will never be complete
		 */
		override public function step():Boolean
		{
			if (!cg || cg.isDefeatedPaused) return false;		// quit if ship is exploding
			
			if (hp != 0)
			{
				if (highFive > 0)
				{
					highFive--;
					if (cg.players[0].highFive > 0 && cg.players[1].highFive > 0)
					{
						mc_object.gotoAndStop("five");
						highFive = 0;
						
						var other:Player = cg.players[1 - playerID];
						other.mc_object.gotoAndStop("five");
						other.highFive = 0;
						
						cg.addDecor("five", { "scale": 2, "x":(mc_object.x + other.mc_object.x) * .5, "y":(mc_object.y + other.mc_object.y) * .5 - 40 } );
						cg.reactToFive();
					}
					if (highFive == 1)
					{
						mc_object.gotoAndStop(mc_object.idleFallback);
					}
				}
				
				handleKeyboard();
				if (countPDW > 0)	// update PDW cooldown
					countPDW--;
					
				if (mc_object.currentFrameLabel == "five") return false;					
				var prev:Boolean = mc_object.prompt.visible;
				mc_object.prompt.visible = highFiveCheck();
			}
			else					// update S.O.S. module UI
			{
				if (reviveExpire > 0 && --reviveExpire == 0)
					reviveProgress = 0;
				reviveCounter = System.changeWithLimit(reviveCounter, 1, 0, System.SECOND * 999);
				cg.hudConsoles[playerID].mod.tf_downtime.text = int(reviveCounter / System.SECOND).toString() + "s";
				cg.hudConsoles[playerID].mod.tf_revive.text = int(reviveProgress * 100).toString() + "%";
				if (reviveCounter % 30 == 0)
					SoundManager.playSFX("sfx_ekg", .7);
			}
			return false;
		}
		
		/**
		 * Helper to update the S.O.S. revive %
		 * @param	progress		Number, percent of the way to a finished revive
		 */
		public function updateReviveUI(progress:Number):void
		{
			reviveExpire = 2;
			reviveProgress = progress;
		}
		
		/**
		 * Revive an incapacitated player by setting its HP to something > 0
		 */
		public function revive():void
		{
			if (hp != 0) return;
			changeHP(hpMax * .4);
			mc_object.alpha = 1;
			reviveProgress = 0;
			reviveCounter = 0;
			reviveExpire = 0;
			mc_object.gotoAndStop("idle_front");
			mc_object.mc_sos.visible = false;
			
			keysDown[RIGHT] = false;
			keysDown[UP] = false;
			keysDown[LEFT] = false;
			keysDown[DOWN] = false;
		
			cg.hudConsoles[playerID].gotoAndStop("none");
		}
		
		override public function changeHP(amt:Number):Boolean
		{
			hp = System.changeWithLimit(hp, amt, 0, hpMax);		
						
			// stop using consoles/items if incapacitated
			if (hp == 0 && reviveCounter == 0)
			{
				onCancel();
				mc_object.gotoAndStop("incap");
				mc_object.mc_sos.visible = true;
				mc_object.mc_sos.scaleX = mc_object.scaleX;
				
				cg.hudConsoles[playerID].gotoAndStop("incap");
				reviveProgress = 0;
				reviveCounter = 0;
				reviveExpire = 0;
				
				SoundManager.playSFX("sfx_warn2vitals", .75);
				
				if (cg.players[0].getHP() == 0 && cg.players[1].getHP() == 0)
					cg.isAllIncap = true;
			}
			
			if (amt < 0 && hp > 0)
				cg.painIndicators[playerID].gotoAndPlay(2);
			
			if (hp != hpMax)
			{
				mc_object.mc_bar.visible = true;
				mc_object.mc_bar.bar.width = (hp / hpMax) * BAR_WIDTH;
				bigBar.width = (hp / hpMax) * 227.7;
			}
			else
				mc_object.mc_bar.visible = false;
				
			return hp == 0;
		}
		
		/**
		 * Update state according to keyboard state
		 */
		private function handleKeyboard():void
		{
			if (!cg || cg.isDefeatedPaused) return;		// quit if ship is exploding
			
			if (!rooted)
			{
				if (keysDown[RIGHT])
				{
					updatePosition(moveSpeed, 0);
					facing = RIGHT;
				}
				if (keysDown[UP])
				{
					updatePosition(0, -moveSpeed);
					facing = UP;
				}
				if (keysDown[LEFT])
				{
					updatePosition( -moveSpeed, 0);
					facing = LEFT;
				}
				if (keysDown[DOWN])
				{
					updatePosition(0, moveSpeed);
					facing = DOWN;
				}
				if (keysDown[CANCEL] && countPDW == 0)
				{
					handlePDW();
				}
			}
			if (activeConsole != null)
			{
				activeConsole.holdKey([keysDown[RIGHT], keysDown[UP], keysDown[LEFT], keysDown[DOWN], keysDown[ACTION]]);
			}
		}
		
		/**
		 * Fire the PDW
		 */
		private function handlePDW():void
		{
			if (!cg || cg.isDefeatedPaused) return;		// quit if ship is exploding
			
			var shot:ABST_IProjectile = new IProjectileGeneric(cg, new SWC_Bullet(), hitMask,
																	{	 
																		"affiliation":	System.AFFIL_PLAYER,
																		"dir":			facing * -90 + System.getRandNum(-2, 2),
																		"dmg":			damagePDW,
																		"life":			30,
																		"pos":			new Point(mc_object.x, mc_object.y - 20),
																		"spd":			9,
																		"style":		null,
																		"scale":		0.75
																	});
			cg.addToGame(shot, System.M_IPROJECTILE);
			countPDW = cooldownPDW;
		}
		
		// tell ManagerDepth to update all depth-managed object's depths when this Player moves
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			if (activeConsole == null)
				manProx.updateProximities(this);
			super.updatePosition(dx, dy);
		}
		
		private function highFiveCheck():Boolean
		{
			if (activeConsole != null || hp == 0 || highFive != 0)
				return false;
			if (keysDown[RIGHT] || keysDown[UP] || keysDown[LEFT] || keysDown[DOWN])
				return false;
			if (facing == 1 || facing == 3)
				return false;
			var other:Player = cg.players[1 - playerID];
			if (other.facing == 1 || other.facing == 3)
				return false;
			var dist:Number = getDistance(other);
			if (dist < 22 || dist > 40)
				return false;
			if (Math.abs(mc_object.y - other.mc_object.y) > 15)
				return false;
			var isLeft:Boolean = mc_object.x < other.mc_object.x;
			if (isLeft && (facing != 0 || other.facing != 2))
				return false;
			if (!isLeft && (facing != 2 || other.facing != 0))
				return false;
			return true;
		}
		
		/**
		 * Set this Player's active console to the one provided
		 * Called by ABST_Console
		 * @param	console		an ABST_Console that is not in use to be used by this Player
		 * @param	isRooted	true if the player shouldn't be able to move when using the console
		 */
		public function sitAtConsole(console:ABST_Console, isRooted:Boolean = true):void
		{
			activeConsole = console;
			rooted = isRooted;
			if (rooted)
				mc_object.gotoAndStop("console");
		}
		
		/**
		 * Set this Player's active console to none, and if there was an active console, free it
		 */
		public function onCancel():void
		{
			if (activeConsole != null)
			{
				activeConsole.onCancel();
				activeConsole = null;
				if (rooted)
					mc_object.gotoAndStop("idle_front");
				rooted = false;
				manProx.updateProximities(this);
				updateDepth();
			}
		}
		
		/**
		 * Update state of keys when a key is pressed
		 * @param	e		KeyboardEvent with info
		 */
		public function downKeyboard(e:KeyboardEvent):void
		{
			if (!cg || cg.isDefeatedPaused) return;		// quit if ship is exploding
			if (mc_object.currentFrameLabel == "five") return;
			
			if (cg.isTruePaused())		
			{
				if (e.keyCode == KEY_ACTION && cg.tails.isActive())		// only allow acknowledgement to go through
					cg.onAction(this);
				return;
			}
			
			if (hp == 0) return;
			
			var pressed:Boolean = false;
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					if (!rooted)
					{
						mc_object.scaleX = 1;
						mc_object.mc_bar.scaleX = 1;
						mc_object.prompt.scaleX = 1;
						pressed = true;
					}
					else if (!keysDown[RIGHT])
					{
						activeConsole.onKey(0);
					}
					keysDown[RIGHT] = true;
				break;
				case KEY_UP:
					if (!rooted)
					{
						pressed = true;
					}
					else if (!keysDown[UP])
					{
						activeConsole.onKey(1);
					}
					keysDown[UP] = true;
				break;
				case KEY_LEFT:
					if (!rooted)
					{
						mc_object.scaleX = -1;
						mc_object.mc_bar.scaleX = -1;
						mc_object.prompt.scaleX = -1;
						pressed = true;
					}
					else if (!keysDown[LEFT])
					{
						activeConsole.onKey(2);
					}
					keysDown[LEFT] = true;
				break;
				case KEY_DOWN:
					if (!rooted)
					{
						pressed = true;
					}
					else if (!keysDown[DOWN])
					{
						activeConsole.onKey(3);
					}
					keysDown[DOWN] = true;
				break;
				case KEY_ACTION:
					if (mc_object.prompt.visible && highFive == 0)
					{
						mc_object.prompt.visible = false;
						highFive = 90;
						mc_object.gotoAndStop("idle_five");
					}
					else if (!rooted)
					{
						cg.onAction(this);
					}
					else if (!keysDown[ACTION])
					{
						activeConsole.onKey(4);
					}
					keysDown[ACTION] = true;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = true;
					onCancel();
				break;
			}
			
			updateAnimation(false);
		}
		
		/**
		 * Update state of keys when a key is released
		 * @param	e		KeyboardEvent with info
		 */
		public function upKeyboard(e:KeyboardEvent):void
		{
			if (!cg || cg.isDefeatedPaused) return;		// quit if ship is exploding
			if (hp == 0) return;
			
			var released:Boolean = false;
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					keysDown[RIGHT] = false;
					released = true;
				break;
				case KEY_UP:
					keysDown[UP] = false;
					released = true;
				break;
				case KEY_LEFT:
					keysDown[LEFT] = false;
					released = true;
				break;
				case KEY_DOWN:
					keysDown[DOWN] = false;
					released = true;
				break;
				case KEY_ACTION:
					keysDown[ACTION] = false;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = false;
				break;
			}
			
			updateAnimation(released);
		}
		
		private function updateAnimation(released:Boolean, forceUpdate:Boolean = false):void
		{
			if (((released && isMoving) || forceUpdate) && !keysDown[RIGHT] && !keysDown[UP] && !keysDown[LEFT] && !keysDown[DOWN])		// stopped moving
			{
				mc_object.gotoAndStop(mc_object.idleFallback);
				isMoving = false;
			}
			else if (!rooted)
			{
				var bx:int = (keysDown[RIGHT] ? 1 : 0) + (keysDown[LEFT] ? -1 : 0);
				var by:int = (keysDown[DOWN] ? 1 : 0) + (keysDown[UP] ? -1 : 0);
					
				if (bx != 0 && (!isMoving || mc_object.idleFallback != "idle_side"))
					mc_object.gotoAndPlay("walk_side");
				if (by == -1 && (!isMoving || mc_object.idleFallback != "idle_rear"))
					mc_object.gotoAndPlay("walk_rear");
				else if (by == 1 && (!isMoving || mc_object.idleFallback != "idle_front"))
					mc_object.gotoAndPlay("walk_front");
					
				if (bx != 0 || by != 0)
					isMoving = true;
			}
		}
		
		override public function destroy():void
		{
			if (cg && cg.stage)
			{
				cg.stage.removeEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
				cg.stage.removeEventListener(KeyboardEvent.KEY_UP, upKeyboard);
			}
			cg = null;
			mc_object = null;
			manProx = null;
			bigBar = null;
			
			super.destroy();
		}
	}
}