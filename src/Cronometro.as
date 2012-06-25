package  
{
	import cepa.utils.Cronometer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Luciano
	 */
	public class Cronometro extends MovieClip
	{
		var cronometer:Cronometer = new Cronometer();
		
		public function Cronometro() 
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.time.text = "0";
			//this.decimos.text = "0";
			
			//var timer:Timer = new Timer(100);
			//timer.addEventListener(TimerEvent.TIMER, atualiza);
			//timer.start();
			
			this.start_btn.addEventListener(MouseEvent.CLICK, startStopClock);
			this.reset_btn.addEventListener(MouseEvent.CLICK, resetClock);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		}
		
		private function keyDownListener(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE) {
				startStopClock(null);
			}
		}
		
		private function atualiza(event:Event):void {
			if (cronometer.read() >= 60000) cronometer.reset();
			var t:Number = cronometer.read() / 1000;
			this.time.text = t.toFixed(1);
			//this.decimos.text = Math.floor((t - Math.floor(t)) * 10).toString();
		}
		
		private function startStopClock(event:MouseEvent):void {
			if (cronometer.isRunning()) {
				cronometer.pause();
				removeEventListener(Event.ENTER_FRAME, atualiza);
			}
			else {
				addEventListener(Event.ENTER_FRAME, atualiza);
				cronometer.start();
			}
			//if (event.target.currentFrame == 1) event.target.gotoAndStop(2);
			//else event.target.gotoAndStop(1);
		}
		
		public function resetClock(event:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, atualiza);
			this.time.text = "0";
			//this.decimos.text = "0";
			cronometer.stop();
			cronometer.reset();
			//event.target.gotoAndStop(1);
			//start_btn.gotoAndStop(1);
		}
		
		public function isRunning():Boolean
		{
			return cronometer.isRunning();
		}
		
		public function pause():void
		{
			cronometer.pause();
		}
		
		public function start():void
		{
			cronometer.start();
		}
		
	}
}