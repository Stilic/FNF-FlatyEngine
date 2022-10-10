package modchart.modifiers;

class Modifier
{
	public var name(default, null):String;

	public var parent:Modifier;

	var subMods:Array<Modifier> = [];

	public function new(name:String)
	{
		this.name = name;
	}

	public function shouldUpdate()
	{
		return false;
	}

	public function getAllSubMods()
	{
		return subMods;
	}

	public function registerSubMod(mod:Modifier)
	{
		if (!subMods.contains(mod))
		{
			mod.parent = this;
			subMods.push(mod);
		}
	}

	public function removeSubMod(mod:Modifier)
	{
		if (subMods.contains(mod))
		{
			mod.parent = null;
			subMods.remove(mod);
		}
	}

	public function setPos(note:Note, baseX:Float = 0, baseY:Float = 0, direction:Float = 90, downscroll:Bool = false, speed:Float = 1)
	{
		for (mod in subMods)
			mod.setPos(note, baseX, baseY, direction, downscroll, speed);
	}

	public function updateNote(note:Note)
	{
		for (mod in subMods)
		{
			if (mod.shouldUpdate())
				mod.updateNote(note);
		}
	}

	public function updateReceptor(receptor:Receptor)
	{
		for (mod in subMods)
		{
			if (mod.shouldUpdate())
				mod.updateReceptor(receptor);
		}
	}
}
