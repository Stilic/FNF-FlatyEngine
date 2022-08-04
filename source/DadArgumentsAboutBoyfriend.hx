package;

class DadArgumentsAboutBoyfriend
{
	var arguments:Array<String> = [
		'stolen my own daughter',
		'can\'t talk in a cool way',
		'pissed my wife in a rap battle',
		'defeated ALL my servants',
		'killed my mom'
	];

	public function new(?additionalArguments:Array<String>)
	{
		if (additionalArguments != null)
			arguments = arguments.concat(additionalArguments);
	}

	public function addArgument(argument:String)
	{
		trace('holy shit new argument 😐');
		arguments.push(argument);
	}

	public function sayWhyBoyfriendSucks()
	{
		trace('true list of arguments:');
		for (arg in arguments)
			trace(arg);
	}
}
