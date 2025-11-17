(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 2;
Server.supernova;
s.reboot;
MIDIIn.connectAll;
s.waitForBoot {
	// Run the setup
	r {
		"synthdefs.scd".loadRelative;
		// Create the effects busses
		~busses = ();
		// Create the reverb bus
		~busses.reverb = Bus.audio(s, s.options.numOutputBusChannels);
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
}
)
(
~config = (
	sinHitPanRange: 0.125
);
// This is a 8 x 8 map from [36..99]
~nnMap = (
	// Row 1
	92: { ~routines.longIntro.play; },
	84: { ~routinesattackFromEverywhere.play; },
	76: {
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, 0.6,
			\freq, 100,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, 0,
			\oscDefect, 0.1
		], ~parGroup);
	},
	68: {
		Synth(\horseGallop, [
			\bufnumL, ~samples.gallopsL,
			\bufnumR, ~samples.gallopsR,
			\rateScale, rrand(0.8, 1.2),
			\dur, rrand(10, 20),
			\pan, rrand(-1, 1),
			\spread, rrand(0, 1.0)

		], ~parGroup);
	},
	60: {
		var samp = ~samples.neighs.choose;
		Synth(\horseGallop, [
			\bufnumL, samp,
			\bufnumR, samp,
			\rateScale, rrand(0.8, 1.2),
			\dur, rrand(1, 3),
			\pan, rrand(-1.0, 1),
			\spread, 0,
			\grainRate, 5,
			\grainDur, 0.6

		]);
	},
	52: { | velocity |
		Synth(\percussiveNoise, [\bufnum, ~convolutionBuffers.choose, \amp, 0.1 * velocity / 127, \release, 0.2 * velocity / 127], ~parGroup);
	},
	44: { | velocity |
		Synth(\bassDrum, [\amp, velocity / 127 * 0.5, \releaseTime, 4]);
	},
	36: { | velocity |
		var createSynth = {
			~vocoder = Synth(\vocoder, [\amp, 2, \oscDefect, 1]);
			NodeWatcher.register(~vocoder);
		};
		if(~vocoder == nil, createSynth, {
			if(~vocoder.isPlaying, {
				~vocoder.release;
				~vocoder = nil;
			}, createSynth)
		});
	},
	// 2nd Column
	37: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, 0.2,
			\reverb
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	45: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	53: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	61: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	69: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	77: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	85: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	93: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 4200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	// 3rd Column
	38: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	46: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	54: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	62: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	70: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	78: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	86: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	},
	94: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel / 127
		], ~parGroup);
	}
);
MIDIdef.noteOn(\test, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	nn.postln;
	~nnMap[nn].(vel);
});)
~routines.longIntro.play;