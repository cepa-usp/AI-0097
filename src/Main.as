package  
{
	/**
	 * ...
	 * @author Brunno
	 */
	
	import BaseAssets.BaseMain;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.accessibility.Accessibility;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import pipwerks.SCORM
	import flash.filters.*;
	import cepa.utils.Cronometer;
	import flash.utils.Timer;
	
	public class Main extends BaseMain
	{
		private var paramObj:Object = new Object();//objeto de parametro inicializado sempre em 0
		private var twn:Array;//movimentação dos planetas
		private var planet01:Planeta01 = new Planeta01();
		private var planet02:Planeta02 = new Planeta02();
		private var planet03:Planeta03 = new Planeta03();
		private var planet04:Planeta04 = new Planeta04();
		private var planet05:Planeta05 = new Planeta05();
		private var planet06:Planeta06 = new Planeta06();
		private var planet07:Planeta07 = new Planeta07();
		private var rad:int = 30;//raio
		private var raioMAX:int = 215;
		private var raioMIN:int = 30;
		private var defaultTime:Number = 10;
		private var numPlanets:int = 7;
		private var numIncPlanets:int;
		private var defaultCorrect:int;
		private var planets:Array;
		private var raios:Array;
		private var sprites:Array;
		private var spritesFake:Array;
		private var userResp:Array;
		private var crono:Cronometer;
		private var errados:int;
		private var posSol:Point;
		
		private var glowFilter:GlowFilter = new GlowFilter();
		private var listSortPeriodos:Array;
		
		private var valendoBoolean:Boolean;
				
		public function Main()
		{
			if (stage) stageDependentInit();
			else addEventListener(Event.ADDED_TO_STAGE, stageDependentInit);
		}
		
		private function stageDependentInit(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageDependentInit);
			
			boxText.visible = false;
			telaValendo.visible = false;
			valendoBoolean = false;
			
			posSol = new Point(sol.x, sol.y);
			
			paramObj.a = 0;
			paramObj.b = 0;
			paramObj.c = 0;
			paramObj.d = 0;
			paramObj.e = 0;
			paramObj.f = 0;
			paramObj.g = 0;
			
			numIncPlanets = 3;
			
			glowFilter.color = 0xFFFFFF;
			glowFilter.blurX = 10;
			glowFilter.blurY = 10;
			glowFilter.alpha = 1;
			glowFilter.strength = 2;
			glowFilter.quality = 1;
			
			planets = new Array();
			sprites = new Array();
			spritesFake = new Array();
			crono = new Cronometer();
			
			for (var i = 0; i < numPlanets; i++)
			{
				sprites[i] = new Sprite();
				addChild(sprites[i]);
				planets[i] = this["planet0" + (i + 1)];
				addChild(planets[i]);
				spritesFake[i] = new Sprite();
				addChild(spritesFake[i]);
			}
			
			sortExercice();
			enterFrameFunction(null);
			
			validar.addEventListener(MouseEvent.CLICK, conferir);
			btnProx.addEventListener(MouseEvent.CLICK, reset);
			valendoNota.addEventListener(MouseEvent.CLICK, openTelaValendo);
			
			initLMSConnection();
			
			verificaStatus();
		}
		
		private function verificaStatus():void
		{
			
			if (completed) {
				valendoNota.visible = false;
				valendoBoolean = false;
			}
			else {
				if (lastTimes > 0){
					valendoNota.visible = false;
					valendoBoolean = true;
				}
				else {
					valendoNota.visible = true;
					valendoBoolean = false;
				}
			}
		}
		
		private function conferir(e:MouseEvent):void 
		{
			//trace("sorteados: " + listSortPeriodos);
			//trace("user: " + userResp);
			trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>");
			var testador:int = 0;
			for (var j = 0; j < userResp.length; j++)
			{
				for each(var teste in listSortPeriodos)
				{
					trace("Compara: " + spritesFake.indexOf(userResp[j]) + " é igual " + planets.indexOf(teste));
					if (spritesFake.indexOf(userResp[j]) == planets.indexOf(teste)) {testador++; trace("é");}
					
				}
			}
			if (valendoBoolean) {
				if (testador == errados)
				{
					acertou.gotoAndPlay(2);
					lastScore += Math.round(100 / 6);
					lastTimes += 1;
				} else {
					errou.gotoAndPlay(2);
					lastTimes += 1;
				}
				save2LMS();
				if (lastTimes == 6) valendoBoolean = false;
			}else {
				if (testador == errados) acertou.gotoAndPlay(2);
				else errou.gotoAndPlay(2);
			}
			unlock(btnProx);
			unlock(botoes.resetButton);
			lock(validar);
			for (var i = 0; i < numPlanets; i++)
			{
				if(spritesFake[i].hasEventListener(MouseEvent.MOUSE_OVER)) spritesFake[i].removeEventListener(MouseEvent.MOUSE_OVER, overLine);
				if(spritesFake[i].hasEventListener(MouseEvent.MOUSE_OUT)) spritesFake[i].removeEventListener(MouseEvent.MOUSE_OUT, outLine);
				if (spritesFake[i].hasEventListener(MouseEvent.CLICK)) spritesFake[i].removeEventListener(MouseEvent.CLICK, clickLine);
			}
		}
		
		private function enterFrameFunction(e:Event):void 
		{
			if (userResp.length < errados || userResp.length > errados)
			{
				lock(validar);
			}else if (userResp.length == errados){
				unlock(validar);
			}
		}
		
		private function openTelaValendo(e:MouseEvent):void 
		{
			setChildIndex(telaValendo, numChildren - 1);
			telaValendo.visible = true;
			telaValendo.okBtn.addEventListener(MouseEvent.CLICK, fazExercicioValer);
			telaValendo.cancelBtn.addEventListener(MouseEvent.CLICK, fechaJanela);
			
		}
		
		private function fazExercicioValer(e:MouseEvent):void 
		{
			fechaJanela(null);
			
			valendoBoolean = true;
			lock(valendoNota);
			telaValendo.okBtn.removeEventListener(MouseEvent.CLICK, fazExercicioValer);
			telaValendo.cancelBtn.removeEventListener(MouseEvent.CLICK, fechaJanela);
		}
		
		private function fechaJanela(e:MouseEvent = null):void 
		{
			telaValendo.visible = false;
			telaValendo.okBtn.removeEventListener(MouseEvent.CLICK, fazExercicioValer);
			telaValendo.cancelBtn.removeEventListener(MouseEvent.CLICK, fechaJanela);
		}
		
		private function mover(e:TweenEvent):void 
		{
			planets[0].x = posSol.x + raios[0] * Math.cos(Math.PI * paramObj.a / 180);
			planets[0].y = posSol.y + raios[0] * Math.sin(Math.PI * paramObj.a / 180);
			
			planets[1].x = posSol.x + raios[1] * Math.cos(Math.PI * paramObj.b / 180);
			planets[1].y = posSol.y + raios[1] * Math.sin(Math.PI * paramObj.b / 180);
			
			planets[2].x = posSol.x + raios[2] * Math.cos(Math.PI * paramObj.c / 180);
			planets[2].y = posSol.y + raios[2] * Math.sin(Math.PI * paramObj.c / 180);
			
			planets[3].x = posSol.x + raios[3] * Math.cos(Math.PI * paramObj.d / 180);
			planets[3].y = posSol.y + raios[3] * Math.sin(Math.PI * paramObj.d / 180);
			
			planets[4].x = posSol.x + raios[4] * Math.cos(Math.PI * paramObj.e / 180);
			planets[4].y = posSol.y + raios[4] * Math.sin(Math.PI * paramObj.e / 180);
			
			planets[5].x = posSol.x + raios[5] * Math.cos(Math.PI * paramObj.f / 180);
			planets[5].y = posSol.y + raios[5] * Math.sin(Math.PI * paramObj.f / 180);
			
			planets[6].x = posSol.x + raios[6] * Math.cos(Math.PI * paramObj.g / 180);
			planets[6].y = posSol.y + raios[6] * Math.sin(Math.PI * paramObj.g / 180);
		}
		
		private function sortExercice():void
		{
			var conta;
			var listSort;
			var certos;
			
			cron.resetClock(null);
			
			listSortPeriodos = new Array();
			raios = new Array();
			twn = new Array();
			userResp = new Array();
			
			lock(btnProx);
			lock(botoes.resetButton);

			for (var i = 0; i < numPlanets; i++)
			{
				raios[i] = 30 + (i * raioMAX/numPlanets);
				
				sprites[i].graphics.clear();
				sprites[i].graphics.lineStyle(2, 0xCCCCCC, 0.3);
				sprites[i].graphics.drawCircle(posSol.x, posSol.y, raios[i]);
				sprites[i].filters = [];
				
				spritesFake[i].graphics.clear();
				spritesFake[i].graphics.lineStyle(15, 0xCCCCCC, 0);
				spritesFake[i].graphics.drawCircle(posSol.x, posSol.y, raios[i]);

				spritesFake[i].buttonMode = true;
				if(!spritesFake[i].hasEventListener(MouseEvent.MOUSE_OVER)) spritesFake[i].addEventListener(MouseEvent.MOUSE_OVER, overLine);
				if(!spritesFake[i].hasEventListener(MouseEvent.MOUSE_OUT)) spritesFake[i].addEventListener(MouseEvent.MOUSE_OUT, outLine);
				if(!spritesFake[i].hasEventListener(MouseEvent.CLICK)) spritesFake[i].addEventListener(MouseEvent.CLICK, clickLine);
				
				sprites[i].visible = false;
				spritesFake[i].visible = false;
				planets[i].visible = false;
			}
			
			certos = rand(4, 7);
			switch(certos)
			{
				case 4: errados = 1; break;
				case 5: errados = 1; break;
				case 6: errados = 2; break;
				case 7: errados = 3; break;
			}
			
			listSort = sort(certos, planets);
			for (var k = 0; k < listSort.length; k++)
			{
				listSort[k].visible = true;
				sprites[planets.indexOf(listSort[k])].visible = true;
				spritesFake[planets.indexOf(listSort[k])].visible = true;
			}
			
			//boxNum.text = String(errados);
			if (errados == 1) infoBar.texto.text = "Selecione " + String(errados) + " planeta que não obedece a Lei de Kepler.";
			else infoBar.texto.text = "Selecione " + String(errados) + " planetas que não obedecem a Lei de Kepler.";
			
			listSortPeriodos = sort(errados, listSort);
			conta = 9 / Math.pow((raios[0]), 3);
							
			paramObj.a = 0;
			paramObj.b = 0;
			paramObj.c = 0;
			paramObj.d = 0;
			paramObj.e = 0;
			paramObj.f = 0;
			paramObj.g = 0;
			
			twn[0] = new Tween(paramObj, "a", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[0]), 3)*conta)*1000, true);
			twn[1] = new Tween(paramObj, "b", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[1]), 3)*conta)*1000, true);
			twn[2] = new Tween(paramObj, "c", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[2]), 3)*conta)*1000, true);
			twn[3] = new Tween(paramObj, "d", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[3]), 3)*conta)*1000, true);
			twn[4] = new Tween(paramObj, "e", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[4]), 3)*conta)*1000, true);
			twn[5] = new Tween(paramObj, "f", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[5]), 3)*conta)*1000, true);
			twn[6] = new Tween(paramObj, "g", None.easeNone, 0, 360*1000, Math.sqrt(Math.pow((raios[6]), 3)*conta)*1000, true);

			if (!twn[0].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[0].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[0].x = posSol.x + raios[0]*Math.cos(Math.PI * paramObj.a/180);
				planets[0].y = posSol.y + raios[0] * Math.sin(Math.PI * paramObj.a / 180);
			} );
			if(!twn[1].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[1].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[1].x = posSol.x + raios[1]*Math.cos(Math.PI * paramObj.b/180);
				planets[1].y = posSol.y + raios[1] * Math.sin(Math.PI * paramObj.b / 180);
			} );
			if(!twn[2].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[2].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[2].x = posSol.x + raios[2]*Math.cos(Math.PI * paramObj.c/180);
				planets[2].y = posSol.y + raios[2] * Math.sin(Math.PI * paramObj.c / 180);
			} );
			if(!twn[3].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[3].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[3].x = posSol.x + raios[3]*Math.cos(Math.PI * paramObj.d/180);
				planets[3].y = posSol.y + raios[3] * Math.sin(Math.PI * paramObj.d / 180);
			} );
			if(!twn[4].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[4].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[4].x = posSol.x + raios[4]*Math.cos(Math.PI * paramObj.e/180);
				planets[4].y = posSol.y + raios[4] * Math.sin(Math.PI * paramObj.e/180);
			} );
			if(!twn[5].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[5].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[5].x = posSol.x + raios[5]*Math.cos(Math.PI * paramObj.f/180);
				planets[5].y = posSol.y + raios[5] * Math.sin(Math.PI * paramObj.f / 180);
			} );
			if(!twn[6].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[6].addEventListener(TweenEvent.MOTION_CHANGE, 
			function ():void { 
				planets[6].x = posSol.x + raios[6]*Math.cos(Math.PI * paramObj.g/180);
				planets[6].y = posSol.y + raios[6] * Math.sin(Math.PI * paramObj.g / 180);
			} );
			/*
			if (!twn[0].hasEventListener(TweenEvent.MOTION_FINISH)) twn[0].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.a = 0; twn[0].start(); } );
			if (!twn[1].hasEventListener(TweenEvent.MOTION_FINISH)) twn[1].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.b = 0; twn[1].start(); } );
			if (!twn[2].hasEventListener(TweenEvent.MOTION_FINISH)) twn[2].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.c = 0; twn[2].start(); } );
			if (!twn[3].hasEventListener(TweenEvent.MOTION_FINISH)) twn[3].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.d = 0; twn[3].start(); } );
			if (!twn[4].hasEventListener(TweenEvent.MOTION_FINISH)) twn[4].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.e = 0; twn[4].start(); } );
			if (!twn[5].hasEventListener(TweenEvent.MOTION_FINISH)) twn[5].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.f = 0; twn[5].start(); } );
			if (!twn[6].hasEventListener(TweenEvent.MOTION_FINISH)) twn[6].addEventListener(TweenEvent.MOTION_FINISH, 
			function ():void { paramObj.g = 0; twn[6].start(); } );
			*/
			for (var j = 0; j < listSortPeriodos.length; j++)
			{
				switch(planets.indexOf(listSortPeriodos[j]))
				{
					case 0: 
						paramObj.a = 0;
						twn[0] = new Tween(paramObj, "a", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[0]), 3) * conta * Math.random()*1.5), true);
						if (!twn[0].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[0].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[0].x = posSol.x + raios[0]*Math.cos(Math.PI * paramObj.a/180);
							planets[0].y = posSol.y + raios[0] * Math.sin(Math.PI * paramObj.a / 180);
						} );
						if (!twn[0].hasEventListener(TweenEvent.MOTION_FINISH)) twn[0].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.a = 0; twn[0].start(); } );
						break;
					case 1: 
						paramObj.b = 0;
						twn[1] = new Tween(paramObj, "b", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[1]), 3) * conta * Math.random()*2), true);
						if(!twn[1].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[1].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[1].x = posSol.x + raios[1]*Math.cos(Math.PI * paramObj.b/180);
							planets[1].y = posSol.y + raios[1] * Math.sin(Math.PI * paramObj.b / 180);
						} );
						if (!twn[1].hasEventListener(TweenEvent.MOTION_FINISH)) twn[1].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.b = 0; twn[1].start(); } );
						break;
					case 2: 
						paramObj.c = 0;
						twn[2] = new Tween(paramObj, "c", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[2]), 3) * conta * Math.random()*2.2), true);
						if(!twn[2].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[2].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[2].x = posSol.x + raios[2]*Math.cos(Math.PI * paramObj.c/180);
							planets[2].y = posSol.y + raios[2] * Math.sin(Math.PI * paramObj.c / 180);
						} );
						if (!twn[2].hasEventListener(TweenEvent.MOTION_FINISH)) twn[2].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.c = 0; twn[2].start(); } );
						break;
					case 3: 
						paramObj.d = 0;
						twn[3] = new Tween(paramObj, "d", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[3]), 3) * conta * Math.random()*2.5), true);
						if(!twn[3].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[3].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[3].x = posSol.x + raios[3]*Math.cos(Math.PI * paramObj.d/180);
							planets[3].y = posSol.y + raios[3] * Math.sin(Math.PI * paramObj.d / 180);
						} );
						if (!twn[3].hasEventListener(TweenEvent.MOTION_FINISH)) twn[3].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.d = 0; twn[3].start(); } );
						break;
					case 4: 
						paramObj.e = 0;
						twn[4] = new Tween(paramObj, "e", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[4]), 3) * conta * Math.random()*3), true);
						if(!twn[4].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[4].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[4].x = posSol.x + raios[4]*Math.cos(Math.PI * paramObj.e/180);
							planets[4].y = posSol.y + raios[4] * Math.sin(Math.PI * paramObj.e/180);
						} );
						if (!twn[4].hasEventListener(TweenEvent.MOTION_FINISH)) twn[4].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.e = 0; twn[4].start(); } );
						break;
					case 5: 
						paramObj.f = 0;
						twn[5] = new Tween(paramObj, "f", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[5]), 3) * conta * Math.random()*4), true);
						if(!twn[5].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[5].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[5].x = posSol.x + raios[5]*Math.cos(Math.PI * paramObj.f/180);
							planets[5].y = posSol.y + raios[5] * Math.sin(Math.PI * paramObj.f / 180);
						} );
						if (!twn[5].hasEventListener(TweenEvent.MOTION_FINISH)) twn[5].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.f = 0; twn[5].start(); } );
						break;
					case 6: 
						paramObj.g = 0;
						twn[6] = new Tween(paramObj, "g", None.easeNone, 0, 360*1000, 1000*Math.sqrt(Math.pow((raios[6]), 3) * conta * Math.random()*5), true);
						if(!twn[6].hasEventListener(TweenEvent.MOTION_CHANGE)) twn[6].addEventListener(TweenEvent.MOTION_CHANGE, 
						function ():void { 
							planets[6].x = posSol.x + raios[6]*Math.cos(Math.PI * paramObj.g/180);
							planets[6].y = posSol.y + raios[6] * Math.sin(Math.PI * paramObj.g / 180);
						} );
						if (!twn[6].hasEventListener(TweenEvent.MOTION_FINISH)) twn[6].addEventListener(TweenEvent.MOTION_FINISH, 
						function ():void { paramObj.g = 0; twn[6].start(); } );
						break;
				}
			}
		}
		
		private function clickLine(e:MouseEvent):void 
		{
			if (Sprite(e.target).buttonMode)
			{
				sprites[spritesFake.indexOf(Sprite(e.target))].filters = [glowFilter];
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.clear();
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.lineStyle(2, 0xFFFFFF, 1);
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.drawCircle(posSol.x, posSol.y, raios[spritesFake.indexOf(Sprite(e.target))]);
				Sprite(e.target).removeEventListener(MouseEvent.MOUSE_OVER, overLine);
				Sprite(e.target).removeEventListener(MouseEvent.MOUSE_OUT, outLine);
				Sprite(e.target).buttonMode = false;
				userResp.push(Sprite(e.target));
				boxText.visible = false;
			}else if (!Sprite(e.target).buttonMode) {
				Sprite(e.target).buttonMode = true;
				sprites[spritesFake.indexOf(Sprite(e.target))].filters = [];
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.clear();
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.lineStyle(2, 0xCCCCCC, 0.3);
				sprites[spritesFake.indexOf(Sprite(e.target))].graphics.drawCircle(posSol.x, posSol.y, raios[spritesFake.indexOf(Sprite(e.target))]);
				Sprite(e.target).addEventListener(MouseEvent.MOUSE_OVER, overLine);
				Sprite(e.target).addEventListener(MouseEvent.MOUSE_OUT, outLine);
				userResp.splice(Sprite(e.target), 1);
				boxText.visible = false;
			}
			enterFrameFunction(null);
		}
		
		private function overLine(e:MouseEvent):void 
		{
			sprites[spritesFake.indexOf(Sprite(e.target))].filters = [glowFilter];
			
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.clear();
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.lineStyle(2, 0xFFFFFF, 1);
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.drawCircle(posSol.x, posSol.y, raios[spritesFake.indexOf(Sprite(e.target))]);
			boxText.x = mouseX+5;
			boxText.y = mouseY-boxText.height-5;
			boxText.visible = true;
			boxText.text = raios[spritesFake.indexOf(Sprite(e.target))].toFixed(2).replace(".", ",") + " km";
			setChildIndex(boxText, numChildren - 1);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingBox);
		}
		
		private function movingBox(e:MouseEvent):void 
		{
			boxText.x = mouseX+5;
			boxText.y = Math.max(5, mouseY-boxText.height-5);
		}
		
		private function outLine(e:MouseEvent):void 
		{
			sprites[spritesFake.indexOf(Sprite(e.target))].filters = [];
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.clear();
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.lineStyle(2, 0xCCCCCC, 0.3);
			sprites[spritesFake.indexOf(Sprite(e.target))].graphics.drawCircle(posSol.x, posSol.y, raios[spritesFake.indexOf(Sprite(e.target))]);
			boxText.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingBox);
		}
		
		/**
		 * Função que calcula inteiros aleatórios entre 2 numeros
		 * @param	min
		 * @param	max
		 * @return  numero inteiro
		 */
		private function rand(min:Number, max:Number):Number {
			var aux;
			aux = Math.floor(Math.random() * (1+max-min)) + min;
			return aux;
		}
		
		private function sort(num:int, list:Array):Array {
			var lista:Array = new Array();
			var teste = list.slice();
			while (lista.length < num)
			{
				var index = rand(0, teste.length-1);
				lista.push(teste[index]);
				teste.splice(index, 1);
			}
			return lista;
		}
		
		
		override public function reset(e:MouseEvent = null):void
		{
			sortExercice();
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
		
		
		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		/* SCORM */
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		
		//SCORM VARIABLES
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormTimeTry:String;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		private var lastTimes:int = 0;//quantas vezes ele ja fez
		private var lastScore:int = 0;//pontuação anterior
		private var maxTimes:int = 6;
		private var respondido:Boolean;
		
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			
			completed = false;
			connected = false;
			
			scorm = new SCORM();

			connected = scorm.connect();
			
			if (connected) {
 
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				
				switch(status)
				{
					// Primeiro acesso à AI// Continuando a AI...
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						scormTimeTry = "times=0,points=0";
						score = 0;
						break;
					
					case "incomplete":
						completed = false;
						scormTimeTry = scorm.get("cmi.location");
						score = 0;
						break;
						
					// A AI já foi completada.
					case "completed"://Apartir desse momento os pontos nao serão mais acumulados
						completed = true;
						scormTimeTry = scorm.get("cmi.location");//Deve contar a quantidade de funções que ele fez e tambem média que ele tinha
						score = 0;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				//Tratamento do scormTimeTry--------------------------------------------------------------------
				if (!completed)//Somente se a atividade nao estiver completa
				{
					var lista:Array = scormTimeTry.split(",");
					for(var i = 0; i < lista.length; i++)
					{
						if(i == 0)
						{
							lastTimes = int(lista[i].substr(lista[i].search("=") + 1));
							
						}else if(i == 1)
						{
							lastScore = int(lista[i].substr(lista[i].search("=") + 1));
							
						}
					}
				}
				
				//----------------------------------------------------------------------------------------------
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					if (pingTimer == null) {
						pingTimer = new Timer(PING_INTERVAL);
						pingTimer.start();
						pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
					}
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				//setMessage("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function save2LMS ()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				lastScore = Math.max(0, Math.min(lastScore, 100));
				var success:Boolean = scorm.set("cmi.score.raw", (lastScore).toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				scormTimeTry = "times=" + lastTimes + ",points=" + lastScore;
				success = scorm.set("cmi.location", scormTimeTry);

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			scorm.get("cmi.completion_status");
		}
		
	}

}