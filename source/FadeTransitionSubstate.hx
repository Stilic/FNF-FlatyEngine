package;

import flixel.addons.transition.TransitionSubstate;
import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;

class FadeTransitionSubstate extends TransitionSubstate
{
	var _finalDelayTime:Float = 0.0;

	public static var nextCamera:FlxCamera;

	var curStatus:TransitionStatus;

	var gradient:FlxSprite;
	var gradientFill:FlxSprite;

	public override function destroy():Void
	{
		super.destroy();
		if (gradient != null)
			gradient.destroy();

		if (gradientFill != null)
			gradientFill.destroy();

		gradient = null;
		gradientFill = null;
		finishCallback = null;
	}

	function onFinish(f:FlxTimer):Void
	{
		if (finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}

	function delayThenFinish():Void
	{
		new FlxTimer().start(_finalDelayTime, onFinish); // force one last render call before exiting
	}

	public override function update(elapsed:Float)
	{
		if (gradientFill != null && gradient != null)
		{
			switch (curStatus)
			{
				case IN:
					gradientFill.y = gradient.y - gradient.height;
				case OUT:
					gradientFill.y = gradient.y + gradient.height;
				default:
			}
		}
		super.update(elapsed);
	}

	override public function start(status:TransitionStatus)
	{
		var cam:FlxCamera = nextCamera != null ? nextCamera : FlxG.cameras.list[FlxG.cameras.list.length - 1];
		nextCamera = null;
		cameras = [cam];

		curStatus = status;
		var zoom:Float = FlxMath.bound(cam.zoom, 0.001);
		var width:Int = Math.ceil(cam.width / zoom);
		var height:Int = Math.ceil(cam.height / zoom);

		gradient = FlxGradient.createGradientFlxSprite(width, height, [FlxColor.BLACK, FlxColor.TRANSPARENT], 1, status == OUT ? 270 : 90);
		gradient.scrollFactor.set();
		gradient.screenCenter(X);
		gradient.y = -height;

		gradientFill = new FlxSprite().makeGraphic(width, height, FlxColor.BLACK);
		gradientFill.screenCenter(X);
		gradientFill.scrollFactor.set();
		add(gradientFill);
		add(gradient);

		FlxTween.tween(gradient, {y: height}, .48, {
			onComplete: function(t:FlxTween)
			{
				delayThenFinish();
			}
		});
	}
}
