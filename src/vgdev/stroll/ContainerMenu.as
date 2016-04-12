package vgdev.stroll
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Main menu and level select screen
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerMenu extends ABST_Container
	{
		private var engine:Engine;
		private var menu:SWC_MainMenu;
		private var checkStory:Boolean = false;
		
		private var tfArr:Array;
		private var blink:int = -1;
		private const BLINK:int = 15;
		private var reassignTF:TextField;

		private var keyDict:Dictionary = getKeyboardDict();
		private var readyToGo:Boolean = false;
		
		private var autoClick:Boolean = false;
		
		/**
		 * A MovieClip handling the main menu
		 * @param	_eng			A reference to the Engine
		 */
		public function ContainerMenu(_eng:Engine)
		{
			engine = _eng;
			
			menu = new SWC_MainMenu();
			addChild(menu);
			menu.addEventListener(Event.ADDED_TO_STAGE, init);
			
			SoundManager.playBGM("bgm_title", System.VOL_BGM);
		}
		
		protected function init(e:Event):void
		{
			menu.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// add primary button listeners
			menu.btn_start.addEventListener(MouseEvent.CLICK, onStart);
			menu.btn_options.addEventListener(MouseEvent.CLICK, onOptions);
			menu.btn_credits.addEventListener(MouseEvent.CLICK, onCredits);
			
			// add submenu button listeners
			menu.mc_options.base.btn_accept.addEventListener(MouseEvent.CLICK, onAcceptOptions);
			menu.mc_credits.base.btn_accept.addEventListener(MouseEvent.CLICK, onAcceptCredits);
			
			var opt:MovieClip = menu.mc_options.base;
			tfArr = [opt.tf_up1, opt.tf_down1, opt.tf_left1, opt.tf_right1, opt.tf_accept1, opt.tf_cancel1,
					 opt.tf_up2, opt.tf_down2, opt.tf_left2, opt.tf_right2, opt.tf_accept2, opt.tf_cancel2];
			
			menu.mc_options.base.tabEnabled = false;
			menu.mc_story.visible = false;
		}
		
		private function onOptions(e:MouseEvent):void
		{
			menu.mc_options.gotoAndPlay("in");
			setKeybindings(true);
			SoundManager.playSFX("sfx_UI_Beep_C");
		}
		
		private function onCredits(e:MouseEvent):void
		{
			menu.mc_credits.gotoAndPlay("in");
			SoundManager.playSFX("sfx_UI_Beep_C");
		}
		
		private function onAcceptOptions(e:MouseEvent):void
		{
			if (readyToGo)
			{
				menu.play();
				
				// clean up listeners
				menu.btn_start.removeEventListener(MouseEvent.CLICK, onStart);
				menu.btn_options.removeEventListener(MouseEvent.CLICK, onOptions);
				menu.btn_credits.removeEventListener(MouseEvent.CLICK, onCredits);
				menu.mc_options.base.btn_accept.removeEventListener(MouseEvent.CLICK, onAcceptOptions);
				menu.mc_credits.base.btn_accept.removeEventListener(MouseEvent.CLICK, onAcceptCredits);
				
				// set up Story
				menu.mc_story.setActionKeys(System.keyMap0["ACTION"], System.keyMap1["ACTION"]);
				checkStory = true;
				SoundManager.playSFX("sfx_readybeep2G");
				
				//completed = true;		// DEBUGGING SHORTCUT -- REMOVE LATER
			}
			else
			{
				setKeybindings(false);
				SoundManager.playSFX("sfx_UI_Beep_Cs");
			}
			menu.mc_options.gotoAndPlay("out");
		}
		
		private function onAcceptCredits(e:MouseEvent):void
		{
			menu.mc_credits.gotoAndPlay("out");
			SoundManager.playSFX("sfx_UI_Beep_Cs");
		}
		
		/**
		 * Set whether or not to listen for keybinding changes in the options menu
		 * @param	isActive
		 */
		private function setKeybindings(isActive:Boolean):void
		{
			if (isActive)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
				menu.mc_options.base.background.addEventListener(MouseEvent.CLICK, onBGClick);
				menu.mc_options.base.btn_defaults.addEventListener(MouseEvent.CLICK, onDefaults);
				
				tfArr[0].text = keycodeToString(System.keyMap0["UP"]);
				tfArr[1].text = keycodeToString(System.keyMap0["DOWN"]);
				tfArr[2].text = keycodeToString(System.keyMap0["LEFT"]);
				tfArr[3].text = keycodeToString(System.keyMap0["RIGHT"]);
				tfArr[4].text = keycodeToString(System.keyMap0["ACTION"]);
				tfArr[5].text = keycodeToString(System.keyMap0["CANCEL"]);
				tfArr[6].text = keycodeToString(System.keyMap1["UP"]);
				tfArr[7].text = keycodeToString(System.keyMap1["DOWN"]);
				tfArr[8].text = keycodeToString(System.keyMap1["LEFT"]);
				tfArr[9].text = keycodeToString(System.keyMap1["RIGHT"]);
				tfArr[10].text = keycodeToString(System.keyMap1["ACTION"]);
				tfArr[11].text = keycodeToString(System.keyMap1["CANCEL"]);
				
				menu.mc_options.base.mc_helper.gotoAndStop("idle");
				
				menu.mc_options.base.btn_useAIL.addEventListener(MouseEvent.CLICK, onAIL);
				menu.mc_options.base.btn_useAIR.addEventListener(MouseEvent.CLICK, onAIR);
				
				setAIvis();
			}
			else
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
				menu.mc_options.base.background.removeEventListener(MouseEvent.CLICK, onBGClick);
				menu.mc_options.base.btn_defaults.removeEventListener(MouseEvent.CLICK, onDefaults);
				menu.mc_options.base.btn_useAIL.removeEventListener(MouseEvent.CLICK, onAIL);
				menu.mc_options.base.btn_useAIR.removeEventListener(MouseEvent.CLICK, onAIR);
			}
			
			var i:int = 0;
			for each (var tf:TextField in tfArr)
			{
				if (isActive)
				{
					tf.addEventListener(MouseEvent.CLICK, onTFClick);
				}
				else
					tf.removeEventListener(MouseEvent.CLICK, onTFClick);
			}
		}
		
		private function onAIL(e:MouseEvent):void
		{
			engine.wingman[0] = !engine.wingman[0];
			onBGClick(null);
			setAIvis();
		}
		
		private function onAIR(e:MouseEvent):void
		{
			engine.wingman[1] = !engine.wingman[1];
			onBGClick(null);
			setAIvis();
		}
		
		private function setAIvis():void
		{
			menu.mc_options.base.mc_aiL.visible = engine.wingman[0];
			menu.mc_options.base.mc_aiR.visible = engine.wingman[1];
		}
		
		private function onDefaults(e:MouseEvent):void
		{
			System.keyMap0 = { };
			System.keyMap1 = { };
			for (var i:* in System.KEYMAP0)
			{
				System.keyMap0[i] = System.KEYMAP0[i];
				System.keyMap1[i] = System.KEYMAP1[i];
			}
			setKeybindings(true);
			checkForConflicts();
			SoundManager.playSFX("sfx_UI_Beep_C");
		}
		
		private function onBGClick(e:MouseEvent):void
		{
			blink = -1;
			if (reassignTF != null)
				reassignTF.visible = true;
			reassignTF = null;
			menu.mc_options.base.mc_helper.visible = true;
			menu.mc_options.base.mc_helper.gotoAndStop("idle");
			SoundManager.playSFX("sfx_UI_Beep_B");
		}
		
		private function onTFClick(e:MouseEvent):void
		{
			blink = BLINK;
			if (reassignTF != null)
				reassignTF.visible = true;
			menu.mc_options.base.mc_helper.visible = true;
			reassignTF = e.target as TextField;
			menu.mc_options.base.mc_helper.gotoAndStop("reassign");
			SoundManager.playSFX("sfx_UI_Beep_C");
		}
		
		private function onKeyPressed(e:KeyboardEvent):void
		{
			if (blink == -1 || reassignTF == null) return;
			
			if (e.keyCode == Keyboard.ESCAPE)
			{
				onBGClick(null);
				return;
			}
			
			switch (reassignTF.name)
			{
				case "tf_up1":		System.keyMap0["UP"] = e.keyCode;		break;
				case "tf_down1":	System.keyMap0["DOWN"] = e.keyCode;		break;
				case "tf_left1":	System.keyMap0["LEFT"] = e.keyCode;		break;
				case "tf_right1":	System.keyMap0["RIGHT"] = e.keyCode;	break;
				case "tf_accept1":	System.keyMap0["ACTION"] = e.keyCode;	break;
				case "tf_cancel1":	System.keyMap0["CANCEL"] = e.keyCode;	break;
				case "tf_up2":		System.keyMap1["UP"] = e.keyCode;		break;
				case "tf_down2":	System.keyMap1["DOWN"] = e.keyCode;		break;
				case "tf_left2":	System.keyMap1["LEFT"] = e.keyCode;		break;
				case "tf_right2":	System.keyMap1["RIGHT"] = e.keyCode;	break;
				case "tf_accept2":	System.keyMap1["ACTION"] = e.keyCode;	break;
				case "tf_cancel2":	System.keyMap1["CANCEL"] = e.keyCode;	break;
			}
			
			reassignTF.text = keycodeToString(e.keyCode);
			blink = -1;
			menu.mc_options.base.mc_helper.visible = true;
			reassignTF.visible = true;
			reassignTF = null;
			menu.mc_options.base.mc_helper.gotoAndStop("idle");
			
			checkForConflicts();
			SoundManager.playSFX("sfx_UI_Beep_Cs");
		}
		
		private function checkForConflicts():Boolean
		{
			var conflict:Boolean = false;
			var codes:Array = [System.keyMap0["UP"], System.keyMap0["DOWN"], System.keyMap0["LEFT"], System.keyMap0["RIGHT"], System.keyMap0["ACTION"], System.keyMap0["CANCEL"],
							   System.keyMap1["UP"], System.keyMap1["DOWN"], System.keyMap1["LEFT"], System.keyMap1["RIGHT"], System.keyMap1["ACTION"], System.keyMap1["CANCEL"]];
			for (var r:int = 0; r < 12; r++)
				tfArr[r].textColor = System.COL_WHITE;
			for (var i:int = 0; i < 12; i++)
			{
				for (var j:int = i + 1; j < 12; j++)
				{
					if (codes[i] == codes[j])
					{
						tfArr[i].textColor = System.COL_RED;
						tfArr[j].textColor = System.COL_RED;
						conflict = true;
					}
				}
			}
			menu.mc_options.base.btn_accept.visible = !conflict;			
			return conflict;
		}
		
		private function keycodeToString(k:uint):String
		{
			var str:String;
			switch (k)
			{
				/*case Keyboard.UP:			str = "↑";			break;
				case Keyboard.DOWN:			str = "↓";			break;
				case Keyboard.LEFT:			str = "←";			break;
				case Keyboard.RIGHT:		str = "→";			break;*/
				case Keyboard.NUMBER_0:		str = "0";			break;
				case Keyboard.NUMBER_1:		str = "1";			break;
				case Keyboard.NUMBER_2:		str = "2";			break;
				case Keyboard.NUMBER_3:		str = "3";			break;
				case Keyboard.NUMBER_4:		str = "4";			break;
				case Keyboard.NUMBER_5:		str = "5";			break;
				case Keyboard.NUMBER_6:		str = "6";			break;
				case Keyboard.NUMBER_7:		str = "7";			break;
				case Keyboard.NUMBER_8:		str = "8";			break;
				case Keyboard.NUMBER_9:		str = "9";			break;
				case Keyboard.COMMA:		str = ",";			break;
				case Keyboard.PERIOD:		str = ".";			break;
				case Keyboard.QUOTE:		str = "'";			break;
				case Keyboard.SEMICOLON:	str = ";";			break;
				case Keyboard.LEFTBRACKET:	str = "[";			break;
				case Keyboard.RIGHTBRACKET:	str = "]";			break;
				case Keyboard.MINUS:		str = "-";			break;
				case Keyboard.EQUAL:		str = "=";			break;
				case Keyboard.BACKQUOTE:	str = "`";			break;
				case Keyboard.BACKSLASH:	str = "\\";			break;
				case Keyboard.SLASH:		str = "/";			break;
				default:
					str = keyDict[k];
					if (str == null)
						str = "Other key";
					str = str.substr(0, 1) + str.substr(1).toLowerCase();
			}
			
			if (str.indexOf("Numpad_") != -1)
				str = "NPad " + str.charAt(7).toUpperCase() + str.substr(8);
			return str;
		}
		
		private function onStart(e:MouseEvent):void
		{
			if (!readyToGo)
			{
				readyToGo = true;
				onOptions(null);
				menu.mc_options.base.mc_title.gotoAndStop(2);
			}
		}
		
		override public function step():Boolean 
		{
			if (blink > 0)
			{
				if (--blink == 0)
					blink = BLINK;
				if (reassignTF != null)
					reassignTF.visible = blink < 12;
				menu.mc_options.base.mc_helper.visible = blink < 12;
			}
			
			if (!checkStory) return completed;
			if (menu.mc_story.currentFrame == menu.mc_story.totalFrames)
			{
				checkStory = false;
				engine.shipColor = menu.mc_story.cp_colorpicker.selectedColor;
				engine.shipName = menu.mc_story.shipName;
				destroy();
				completed = true;
			}
			else
			{
				if (engine.wingman[0])
					menu.stage.dispatchEvent(new KeyboardEvent((autoClick ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP), true, false, 0, System.keyMap0["ACTION"]));
				if (engine.wingman[1])
					menu.stage.dispatchEvent(new KeyboardEvent((autoClick ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP), true, false, 0, System.keyMap1["ACTION"]));
				autoClick = !autoClick;
			}
			return completed;
		}
		
		/**
		 * Called by Story once it's done
		 * @param	col		The color to tint the slipship
		 */
		public function isDone(col:uint):void
		{
			destroy();
			completed = true;
		}
		
		private function getKeyboardDict():Dictionary
		{
			var keyDescription:XML = describeType(Keyboard);
			var keyNames:XMLList = keyDescription..constant.@name;

			var keyboardDict:Dictionary = new Dictionary();

			var len:int = keyNames.length();
			for (var i:int = 0; i < len; i++)
			{
				keyboardDict[Keyboard[keyNames[i]]] = keyNames[i];
			}

			return keyboardDict;
		}
		
		/**
		 * Clean-up code
		 */
		protected function destroy():void
		{
			if (menu != null)
			{
				if (contains(menu))
					removeChild(menu);
			}
			menu = null;
			engine = null;
		}
	}
}
