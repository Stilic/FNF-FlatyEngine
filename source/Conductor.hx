package;

import Song.SwagSong;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

typedef Rating =
{
	var image:String;
	var time:Float;
	var score:Int;
	var mod:Float;
	var splash:Bool;
}

class Conductor
{
	public static var ratings:Array<Rating> = [
		{
			image: 'sick',
			time: 45,
			score: 350,
			mod: 1,
			splash: true
		},
		{
			image: 'good',
			time: 90,
			score: 200,
			mod: 0.7,
			splash: false
		},
		{
			image: 'bad',
			time: 135,
			score: 100,
			mod: 0.4,
			splash: false
		},
		{
			image: 'shit',
			time: 180,
			score: 50,
			mod: 0,
			splash: false
		}
	];
	public static var ranks:Map<Int, String> = [
		100 => "S+",
		90 => "S",
		80 => "A",
		70 => "B",
		60 => "C",
		50 => "D",
		40 => "E",
		10 => "F"
	];

	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function getRating(diff:Float)
	{
		for (i in 0...ratings.length - 1) // skips last window (Shit)
			if (diff <= ratings[i].time)
				return ratings[i];
		return ratings[ratings.length - 1];
	}

	public static function getRank(accuracy:Float)
	{
		accuracy = CoolUtil.floorDecimal(accuracy * 100, 2);

		var lastAccuracy:Int = 0;
		var leRank:String = '';

		for (minAccuracy => rank in ranks)
		{
			if (minAccuracy <= accuracy && minAccuracy >= lastAccuracy)
			{
				lastAccuracy = minAccuracy;
				leRank = rank;
			}
		}

		return leRank;
	}
}
