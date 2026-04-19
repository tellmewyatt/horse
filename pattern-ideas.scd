TempoClock.tempo = 2
(~playsN = { | nn |  };)
(
Event.addEventType(\spoofmidi, {
	var nn = ~nn;
	nn.postln;
	topEnvironment.use {
		~noteMap.midiNoteOn(nn, 127);
	};
});)
(
var patterns = [
	[0,1,0,2,0,2,0,1,2,1,2,1,0],
	[0,1,0,2,0,2,0,1,2,1,2],
	[0,1,0,2,0,2,0,1,2],
	[0,1,0,2,0,2,0],
	[0,2,1,2,0],
	[0,1,2],
	[0,1,0,1,2,1,2,1],
	[0,1,2]
];
~getPattern = { | p, repeats, dur, topBottom, row=0 |
	var seq;
	if (topBottom == \bottom) {
		seq = p + 81 - (row * 10);
	} {
		seq = -1 * p + 88 - (row * 10)
	};
	Pbind(
		\nn, Pseq(seq, repeats),
		\dur, dur,
		\type, \spoofmidi
	);
};
~getSegment = { | pattern, row, longShortRatio=3, notedur=0.25 |
	Pseq(
		[
			Ppar([
			~getPattern.(pattern, 1, notedur * longShortRatio, \bottom, row),
			~getPattern.(pattern, longShortRatio, notedur, \top, row)
		]),
			Ppar([
				~getPattern.(pattern, longShortRatio, notedur, \bottom, row),
				~getPattern.(pattern, 1, notedur * longShortRatio, \top, row)
			])
		]
	)
};
x =Pseq(patterns.collect { | p, i |
	~getSegment.(p, i, 3, 0.25)
} ++ patterns.collect { | p, i |
	~getSegment.(p, i, 2, 0.25)
} ++ patterns.collect { | p, i |
	~getSegment.(p, i, 1, 0.25)
}++ patterns.collect { | p, i |
	~getSegment.(p, i, 1, 1/6)
}).play;
)
x.stop;
~hi
x = (play: { ~noteMap = ~noteMap; ~noteMap.postln; } ).play;
x.play;
Event.parentEven
a = (play: { ~word.scramble.postln }, word: "hello word").play;
(type: \spoofmidi, nn: 81).play;
#