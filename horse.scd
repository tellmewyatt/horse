(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 8;
s.options.hardwareBufferSize = 1024;
Server.supernova;
s.reboot;
"./noteMap.scd".loadRelative;
"./openingMap.scd".loadRelative;
"./config.scd".loadRelative
~noteMap.switchTo(\opening);
~maxOsc = NetAddr.new("127.0.0.1", 5000);
s.waitForBoot {
	// Run the setup
	r {
		"synthdefs.scd".loadRelative;
		// Create the effects busses
		~busses = ();
		// Create the reverb bus
		~busses.reverb = Bus.audio(s, s.options.numOutputBusChannels);
		// Controls RGB video
		~busses.video= (
			rgbScales: Bus.control(s, 3),
			noiseLevel: Bus.control(s, 1),
			saturation: Bus.control(s, 1)
		);
		~samples = ();
		~convolutionBuffers =
		40.collect {
			var buf = Buffer.alloc(s, 1024, 1);
			buf;
		};
		s.sync;
		~convolutionBuffers.collect { | buf |
			buf.setn(0, 1024.collect { rrand(0, 1) }).normalize;
		};
		~samples.whatami = Buffer.readChannel(s, "audio/03.flac".resolveRelative, channels:[0]);
		~samples.gallopsL = Buffer.readChannel(s, "audio/gallops.wav".resolveRelative, channels:[0]);
		~samples.gallopsR = Buffer.readChannel(s, "audio/gallops.wav".resolveRelative, channels:[1]);
		~samples.neighs = PathName("audio/horse-neighs".resolveRelative).entries.collect { | path |
			Buffer.readChannel(s, path.absolutePath, channels:[0])
		};
	}.play;

}
)
(
~reverb = Synth(\reverb, [\in, ~busses.reverb]);
~scaleVideoRGB = Synth.tail(s, \videoControl3, [\in, ~busses.video.rgbScales, \out, ~busses.video.rgbScales]);
~scaleVideoNoise = Synth.tail(s, \videoControl, [\in, ~busses.video.noiseLevel, \out, ~busses.video.noiseLevel]);
~rgbOffset = Synth(\rgbOffset, [\out, ~busses.video.rgbScales]);
~saturationOffset = Synth(\videoOffset, [\out, ~busses.video.saturation]);
// Create the parallel group that will persist forever
~parGroup = ParGroup(s);
~routines = ();
~routines.attackFromEverywhere = r {
	var freqRatio = 0.1;
	var oscDefect = 0;
	while  { freqRatio <= 0.7 } {
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, freqRatio,
			\freq, 450 * [1.6, 1.7, 3.9, 4.3].choose /8,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, rrand(0.1, 1),
			\reverbBus, ~busses.reverb,
			\reverbPreDelay, rrand(0.0, 1),
			\pan, rrand(-1.0, 1),
			\oscDefect, oscDefect
		], ~parGroup);
		([3,5,7, 11].choose / (freqRatio * 10) ).wait;
		freqRatio = freqRatio + 0.01;
		oscDefect = oscDefect + 0.01;
	};
};

~routines.longIntro = r {
	var divRatio = 16;
	var timeElapsed = 0;
	"Playing long intro".postln;
	Synth(\playSample, [\bufnum, ~samples.neighs[0], \amp, 0.2, \pan, 0.125]);
	Synth(\horseGallop, [
		\bufnumL, ~samples.gallopsL,
		\bufnumR, ~samples.gallopsR,
		\rateScale, 1,
		\dur, 20,
		\pan, rrand(-1, 1),
		\spread, rrand(0, 1.0)
	], ~parGroup);
	5.wait;
	while { divRatio >= 1 } {
		"while still".postln;
		divRatio.postln;
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, 0.01,
			\freq, 450 / divRatio,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, rrand(0.1, 1),
			\reverbBus, ~busses.reverb,
			\reverbPreDelay, rrand(0, 1.0),
			\pan, rrand(-1.0, 1),
			\oscDefect, 0

		], ~parGroup);
		divRatio = divRatio / 2;
		(divRatio * 4).wait;
	};
	Pbindef(\horseGallops,
		\instrument, \horseGallop,
		\bufnumL, ~samples.gallopsL,
		\bufnumR, ~samples.gallopsR,
		\rateScale, Pwhite(0.7, 1.5),
		\dur, Pwhite(20, 30),
		\delta, Pwhite(20, 40),
		\pan, Pwhite(-1.0, 1),
		\spread, Pwhite(0, 1.0)
	).play;
	Pbindef(\horseNeighs,
		\instrument, \grainBuf,
		\bufnum, Prand(~samples.neighs, inf),
		\rateScale, Pwhite(0.8, 1.2),
		\dur, Pwhite(1, 2),
		\pan, Pwhite(-1.0, 1),
		\spread, 0,
		\grainRate, 5,
		\grainDur, 0.6,
		\amp, 0.1,
		\delta, Pwhite(20, 40)
	).play;
	120.do {
		timeElapsed = timeElapsed + 1;
		timeElapsed.postln;
		1.wait;
	};
	Pbindef(\horseGallops).stop;
	Pbindef(\horseNeighs).stop;
	~routines.attackFromEverywhere.play;
};
~sendVideoData = r {
	loop {
		~busses.video.rgbScales.get({ | value |
			~maxOsc.sendMsg("/rscale", value[0]);
			~maxOsc.sendMsg("/gscale", value[1]);
			~maxOsc.sendMsg("/bscale", value[2]);
		});
		~busses.video.noiseLevel.get({ | value |
			~maxOsc.sendMsg("/noiseLevel", value);
		});
		~busses.video.saturation.get({ | value |
			~maxOsc.sendMsg("/saturation", value);
		});
		0.01.wait;
	}
}.play;
)
~busses.video.rgbScales.scope;
