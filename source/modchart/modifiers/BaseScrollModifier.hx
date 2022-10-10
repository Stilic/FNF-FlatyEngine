package modchart.modifiers;

class BaseScrollModifier extends Modifier
{
	override function setPos(note:Note, baseX:Float = 0, baseY:Float = 0, direction:Float = 90, downscroll:Bool = false, speed:Float = 1)
	{
		var distance:Float = Note.getDistance(note.strumTime, downscroll, speed);
		var angleDir:Float = (direction * Math.PI) / 180;

		note.x = baseX + note.offsetX + Math.cos(angleDir) * distance;
		note.y = baseY + note.offsetY + Math.sin(angleDir) * distance;

		if (note.isSustainNote)
		{
			note.y += (Note.swagHeight / 1.75) * (downscroll ? 1 : -1);
			if (downscroll)
			{
				note.y += note.height / 1.75;
				if (note.isSustainEnd && note.prevNote != null)
				{
					if (note.sustainEndOffset == Math.NEGATIVE_INFINITY)
					{
						note.sustainEndOffset = (note.prevNote.y - (note.y + note.height - 1));
						if (!note.prevNote.isSustainNote)
							note.sustainEndOffset += note.height / 1.25;
					}
					note.y += note.sustainEndOffset;
				}
			}
		}

		if (note.copyAngle)
			note.angle = direction - 90 + note.offsetAngle;

		super.setPos(note, baseX, baseY, direction, downscroll, speed);
	}
}
