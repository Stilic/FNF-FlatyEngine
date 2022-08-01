package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;

// thingy from psych holy shit
class CustomFadeTransition extends FlxSubState
{
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;

	var isTransIn:Bool = false;
	var leTween:FlxTween = null;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scrollFactor.set();
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		add(transBlack);

		transGradient.x -= (width - FlxG.width) / 2;
		transBlack.x = transGradient.x;

		if (isTransIn)
		{
			transGradient.y = transBlack.y - transBlack.height;
			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.linear
			});
		}
		else
		{
			transGradient.y = -transGradient.height;
			transBlack.y = transGradient.y - transBlack.height + 50;
			leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					if (finishCallback != null)
						finishCallback();
				},
				ease: FlxEase.linear
			});
		}

		if (nextCamera == null)
			nextCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		transBlack.cameras = [nextCamera];
		transGradient.cameras = [nextCamera];
		nextCamera = null;
	}

	function updateTrans()
	{
		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;
	}

	override function update(elapsed:Float)
	{
		updateTrans();
		super.update(elapsed);
		updateTrans();
	}

	override function destroy()
	{
		if (leTween != null)
		{
			if (finishCallback != null)
				finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}
