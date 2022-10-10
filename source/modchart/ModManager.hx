package modchart;

import modchart.modifiers.*;

// i'm so fuckin' pro that i did an entire class to manage some note shit
class ModManager
{
	var mods:Array<Modifier> = [];

	public function new()
	{
	}

	public function registerDefaultMods()
	{
		registerMod(new BaseScrollModifier('baseScroll'));
	}

	public function getAllMods()
	{
		return mods;
	}

	public function registerMod(mod:Modifier)
	{
		if (!mods.contains(mod))
			mods.push(mod);
	}

	public function removeMod(mod:Modifier)
	{
		if (mods.contains(mod))
			mods.remove(mod);
	}

	public function setPos(note:Note, baseX:Float = 0, baseY:Float = 0, direction:Float = 90, downscroll:Bool = false, speed:Float = 1)
	{
		for (mod in mods)
			mod.setPos(note, baseX, baseY, direction, downscroll, speed);
	}

	public function updateNote(note:Note)
	{
		for (mod in mods)
		{
			if (mod.shouldUpdate())
				mod.updateNote(note);
		}
	}

	public function updateReceptor(receptor:Receptor)
	{
		for (mod in mods)
		{
			if (mod.shouldUpdate())
				mod.updateReceptor(receptor);
		}
	}
}
