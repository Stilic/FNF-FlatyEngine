package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxUIState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static function switchState(nextState:FlxState)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			FlxG.state.openSubState(new CustomFadeTransition(0.5, false));
			if (nextState == FlxG.state)
				CustomFadeTransition.finishCallback = FlxG.resetState;
			else
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	inline static public function resetState()
	{
		switchState(FlxG.state);
	}

	override function create()
	{
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if (!skip)
			openSubState(new CustomFadeTransition(0.6, true));
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
