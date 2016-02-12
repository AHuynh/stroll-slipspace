package vgdev.stroll.support 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	
	public class SoundManager 
	{
		
		//[Embed(source="../../../bgm/BGM_mainMenu.mp3")]
		/*private static var bgm_menu:Class;*/
		
		private static var sounds:Object = new Object();
		private static var bgm:SoundChannel;
		
		private static var currentBGM:String = "";
		
		public function SoundManager() 
		{
			trace("WARNING: Should not instantiate SoundManager class!");
		}
		
		public static function playSound(sound:String):void
		{
			var snd:Sound;
			switch (sound)
			{
				default:
					trace("WARNING: No sound located for " + sound + "!");
			}
			if (snd)
				snd.play();
		}
		
		public static function playBGM(music:String):void
		{
			if (currentBGM == music)
				return;
			stopBGM();
			
			var snd:Sound;
			switch (music)
			{
				default:
					trace("WARNING: No music located for " + music + "!");
					return;
			}
			currentBGM = music;
			
			bgm = snd.play(0, 9999);
		}
		
		public static function stopBGM():void
		{
			if (bgm)
			{
				bgm.stop();
				bgm = null;
			}
		}
		
		public static function isBGMplaying():Boolean
		{
			return (bgm != null);
		}
		
		public static function shutUp():void
		{
			SoundMixer.stopAll();
		}
		
	}

}