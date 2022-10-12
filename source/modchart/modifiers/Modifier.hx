package modchart.modifiers;

class Modifier
{
	public var manager(default, null):Modchart;

	public var values:Array<Float> = [];

	public var submods:Map<String, SubModifier> = new Map<String, SubModifier>();

	public function new(manager:Modchart)
	{
		this.manager = manager;
	}

	// override this in your modifier!
	public function getName()
	{
		return '';
	}
}
