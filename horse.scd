(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
Server.supernova;
s.reboot;
MIDIIn.connectAll;
)
~horseBuffer = Buffer.readChannel(s, "horse-recordings/horse-recordings.wav".resolveRelative, channels:[0]);
(
r {
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
SynthDef(\horseGallop, { | bufnumL, bufnumR, dur=5, spread=1, amp=0.2, pan = 0, fadeTime=0.2, rateScale=1.4, out=0, grainRate=2, grainDur=1 |
	var sig;
	sig = Splay.ar([
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumL, BufRateScale.kr(bufnumL) * rateScale, Line.kr(0, 0.9, dur)),
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumR, BufRateScale.kr(bufnumR) * rateScale, Line.kr(0, 0.9, dur))
	], spread, amp, pan);
	sig = sig * EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime]));
	Out.ar(out, sig);
}).add;
SynthDef(\vocoder, { | out = 0, pan=0, amp = 1, oscDefect=0, freq=100, gate=1 |
	var sig = SoundIn.ar(0, 1);
	var pitch = Pitch.kr(sig)[0];
	// Analysis
	var filters = BPF.ar(sig, 200.collect { | i | (i + 1) * 100 }, 0.1, 1);
	var amps = filters.collect { | item | Amplitude.ar(item) };
	// Resynthesis
	var outsig =  amps.collect ({ | amp, i |
		SinOsc.ar((i+ 1) * pitch * (1 + (Rand(-1.0, 1) * oscDefect)), 0, amp);
	}).sum * 2;
	var env = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction: 2);
	outsig = outsig + sig;
	outsig = Pan2.ar(outsig, pan, amp);
	outsig = FreeVerb2.ar(outsig, outsig, 0.2, 1);
	Out.ar(out, outsig * env);
}).add;
SynthDef(\normalizedVocoder, { | amp=0.2, gate=1, freq=200, out=0, bufnum, pan=0, freqRatio=1, convolutionBuffer, reverbMix=1, oscDefect=0, envCurve= -4 |
	// Vocoder section
	var insig = PlayBuf.ar(
		1,
		bufnum,
		BufRateScale.kr(bufnum) * freqRatio
	);
	// Analysis
	var filters = BPF.ar(insig, 100.collect { | i | (i + 1) * 100 * freqRatio }, 0.1, 1);
	var amps = filters.collect { | item | Amplitude.ar(item) };
	// Resynthesis
	var sig =  amps.collect ({ | amp, i |
		SinOsc.ar((i+ 1) * freq * (1 + (Rand(-1.0, 1) * oscDefect)), 0, amp);
	}).sum * 2;

	var attackTime = 1.5 / freqRatio;
	var env = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime,
			1,
			envCurve
		),
		gate);
	var doneEnv = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime + 5
		),
		gate, doneAction: 2);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = sig +HPF.ar(Convolution2.ar(sig, convolutionBuffer, 0, 1024) * 0.1, 100);
	sig = Pan2.ar(
		sig,
		pan,
		0.5 * amp * env
	);
	sig = FreeVerb2.ar(sig[0], sig[1], reverbMix, 1);
	Out.ar(out, sig);
}).add;
SynthDef(\percussiveNoise, { | amp = 1, pan=0, bufnum, out=0, gate=1, release =0.01 |
	var env = EnvGen.kr(Env([0,1,1,0], [0, 15, 0]), gate, doneAction: 2);
	var sig = PlayBuf.ar(1,bufnum) * 0.8 * EnvGen.ar(Env.perc(0,release));
	sig = Pan2.ar(sig, pan, amp);
	sig = HPF.ar(FreeVerb2.ar(sig, sig, Rand(0.2, 0.5), 1, ExpRand(0.1, 1)), 800);
	Out.ar(out, sig * env);
}).add;
SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, releaseTime=1 |
	var sig = Pan2.ar(
		SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi).mean * amp * EnvGen.kr(Env.perc(0.001, releaseTime), 1, doneAction: 2),
		0);
	Out.ar(out, sig);
}).add;

~parGroup = ParGroup();
~routines = [
	r {
		var divRatio = 16;
		while { divRatio >= 1 } {
			"while still".postln;
			divRatio.postln;
			Synth(\normalizedVocoder, [
				\bufnum, ~samples.whatami,
				\freqRatio, 0.01,
				\freq, 450 / divRatio,
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbMix, rrand(0.1, 1),
				\pan, rrand(-1, 1),
				\oscDefect, 0

			], ~parGroup);
			divRatio = divRatio / 2;
			(divRatio * 4).wait;
		};
		200.wait;
	},
	r {
		var freqRatio = 0.1;
		var oscDefect = 0;
		while  { freqRatio <= 0.7 } {
			Synth(\normalizedVocoder, [
				\bufnum, ~samples.whatami,
				\freqRatio, freqRatio,
				\freq, 450 * [1.6, 1.7, 3.9, 4.3].choose /8,
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbMix, rrand(0.1, 1),
				\pan, rrand(-1, 1),
				\oscDefect, oscDefect
			], ~parGroup);
			([3,5,7, 11].choose / (freqRatio * 10) ).wait;
			freqRatio = freqRatio + 0.01;
			oscDefect = oscDefect + 0.01;
		};
	},
	r {
		10.do {
			Synth(\normalizedVocoder, [
				\bufnum, ~samples.whatami,
				\freqRatio, 0.6,
				\freq, 100,
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbMix, 0.2,
				\pan, 0,
				\oscDefect, 0.1
			], ~parGroup);
			[7, 11, 13, 17].choose.wait;
		}
	},
	r {
		10.do {
			Synth(\normalizedVocoder, [
				\bufnum, ~convolutionBuffers.choose,
				\freqRatio, 0.6,
				\freq, rrand(50, 300),
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbMix, 0.2,
				\pan, rrand(-1.0, 1),
				\oscDefect, 0.1
			], ~parGroup);
			[7, 11, 13, 17].choose.wait;
		}
	}
];
)
(
// This is a 8 x 8 map from [36..99]
~nnMap = (
	// Row 1
	92: { ~routines[0].play; },
	84: { ~routines[1].play; },
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
			\reverbMix, 0.2,
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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
			\pan, rrand(-1.0, 1),
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