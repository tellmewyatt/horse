(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 8;
s.options.hardwareBufferSize = 512;
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
};
~config = (
	sinHitPanRange: 0.125,
	reverbSend: 0.5,
	bassAmp: 0.4,
);
// This is a 8 x 8 map from [36..99]
~noteOffMap = ();
~noteOnMap = (
	// Column 1
	92: { ~routines.longIntro.play; },
	84: { ~routinesattackFromEverywhere.play; },
	76: { | velocity |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, 0.6,
			\freq, 100,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\amp, 0.2 * velocity,
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
		Synth(\percussiveNoise, [\bufnum, ~convolutionBuffers.choose, \amp, 0.1 * velocity, \release, 0.2 * velocity], ~parGroup);
	},
	44: { | velocity |
		Synth(\bassDrum, [\amp, velocity * 0.5, \releaseTime, 4]);
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
			\reverbBus, ~busses.reverb,
			\reverbSend, ~config.reverbSend,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	45: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	53: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	61: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	69: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	77: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	85: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	93: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 4200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	// 3rd Column
	38: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	46: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	54: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	62: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	70: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	78: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	86: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	94: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
	},
	// Row 4
	95: { | vel |
		~noteOffMap[95] = Synth(\bouncyBass, [\freq, 60.midicps, \amp, ~config.bassAmp * vel]);
	},
	87: { | vel |
		~noteOffMap[87] = Synth(\bouncyBass, [\freq, 55.midicps, \amp, ~config.bassAmp * vel]);
	},
	79: { | vel |
		~noteOffMap[79] = Synth(\bouncyBass, [\freq, 50.midicps, \amp, ~config.bassAmp * vel]);
	},
	71: { | vel |
		~noteOffMap[71] = Synth(\bouncyBass, [\freq, 45.midicps, \amp, ~config.bassAmp * vel]);
	},
	63: { | vel |
		~noteOffMap[63] = Synth(\bouncyBass, [\freq, 40.midicps, \amp, ~config.bassAmp * vel]);
	},
	55: { | vel |
		~noteOffMap[55] = Synth(\bouncyBass, [\freq, 35.midicps, \amp, ~config.bassAmp * vel]);
	},
	47: { | vel |
		~noteOffMap[47] = Synth(\bouncyBass, [\freq, 30.midicps, \amp, ~config.bassAmp * vel]);
	},
	39: { | vel |
		~noteOffMap[39] = Synth(\bouncyBass, [\freq, 25.midicps, \amp, ~config.bassAmp * vel]);
	}

);
MIDIdef.noteOn(\noteOns, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	nn.postln;
	~noteOnMap[nn].(vel / 127);
});
MIDIdef.noteOff(\noteOffs, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	nn.postln;
	~noteOffMap[nn].release;
});
)
~routines.longIntro.play;
Synth(\bouncyBass)