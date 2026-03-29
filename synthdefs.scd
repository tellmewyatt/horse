
~channelMaps = (
	2:(
		0: 0,
		1: 1
	),
	4: (
		0: 0,
		1: 1,
		2: 3,
		3: 2
	),
	8: (
		0: 0,
		1: 4,
		2: 1,
		3: 3,
		4: 7,
		5: 5,
		6: 6,
		7: 2
	)
);
// Evenly pans a signal over the specified number of channels, matching the oreination of the CECM studio
~createPanner = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~channelMaps;
	var getInvertedAsArray = { | map |
		var inverted = map.invert;
		inverted.order.collect { | i | inverted[i]; };
	};
	var map = getInvertedAsArray.(channelMaps[nchans]);
	var offset = if(nchans == 8, { 0.25 }, { 0 });
	{ | sig, pos=0, width=2 |
		sig = PanAz.ar(nchans, sig, pos + offset, 1, width, orientation);
		map.collect { | i | sig[i]; }
	};
};
~createSplayer = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~channelMaps;
	var getInvertedAsArray = { | map |
		var inverted = map.invert;
		inverted.order.collect { | i | inverted[i]; };
	};
	var map = getInvertedAsArray.(channelMaps[nchans]);
	var offset = if(nchans == 8, { 0.25 }, { 0 });
	{ | sig, pos=0, width=2, spread=1 |
		sig = SplayAz.ar(nchans, sig, spread, 1, width, pos + offset, orientation);
		map.collect { | i | sig[i]; }
	};
};
~panEvenly = ~createSplayer.();
SynthDef(\playSample, { | amp=0.2, out=0, pan=0, rate=1, bufnum |
	Out.ar(out,
		~panEvenly.(
			PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0, doneAction: 2) * amp,
			pan
		)
	);
}).add;
SynthDef(\horseGallop, { | bufnumL, bufnumR, dur=5, spread=1, amp=0.2, pan = 0, fadeTime=0.2, rateScale=1.4, out=0, grainRate=2, grainDur=1 |
	var sig;
	var env = EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime]), doneAction: 2);
	sig = ~panEvenly.([
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumL, BufRateScale.kr(bufnumL) * rateScale, Line.kr(0, 0.9, dur)) * env,
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumR, BufRateScale.kr(bufnumR) * rateScale, Line.kr(0, 0.9, dur)) * env
	] * amp, pan, 2, Rand(0.1, 1));
	Out.ar(out, sig);
}).add;
SynthDef(\grainBuf, { | bufnum, dur=5, spread=1, amp=0.2, pan = 0, fadeTime=0.2, rateScale=1.4, out=0, grainRate=2, grainDur=1 |
	var sig;
	var env = EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime]), doneAction: 2);
	sig = ~panEvenly.([
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnum, BufRateScale.kr(bufnum) * rateScale, Line.kr(0, 0.9, dur)) * env,
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnum, BufRateScale.kr(bufnum) * rateScale, Line.kr(0, 0.9, dur)) * env
	] * amp, 2, Rand(0.1, 1));
	Out.ar(out, sig);
}).add;
SynthDef(\vocoder, { | out = 0, pan=0, amp = 1, oscDefect=0, freq=100, gate=1, reverbBus, reverbSend=0 |
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
	outsig = ~panEvenly.(outsig * amp * env, pan);
	Out.ar(reverbBus, outsig * reverbSend);
	Out.ar(out, outsig);
}).add;
SynthDef(\normalizedVocoder, { | amp=0.2, gate=1, freq=200, out=0, bufnum, pan=0, freqRatio=1, convolutionBuffer, oscDefect=0, envCurve= -4, reverbBus, reverbSend=0, reverbPreDelay=0 |
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
		gate,
		doneAction: 2
	);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = sig +HPF.ar(Convolution2.ar(sig, convolutionBuffer, 0, 1024) * 0.1, 100);
	sig = ~panEvenly.(
		sig * 0.5 * amp * env,
		pan
	);
	Out.ar(reverbBus,
		DelayN.ar(reverbSend * sig, 0.2, 2 * reverbPreDelay)
	);
	Out.ar(out, sig);
}).add;
SynthDef(\percussiveNoise, { | amp = 1, pan=0, bufnum, out=0, gate=1, release =0.01 |
	var env = EnvGen.kr(Env([0,1,1,0], [0, 15, 0]), gate, doneAction: 2);
	var sig = PlayBuf.ar(1,bufnum) * 0.8 * EnvGen.ar(Env.perc(0,release));
	sig = ~panEvenly.(sig * amp, pan);
	sig = HPF.ar(FreeVerb.ar(sig, Rand(0.2, 0.5), 1, ExpRand(0.1, 1)), 800);
	Out.ar(out, sig * env);
}).add;
SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, releaseTime=1 |
	var sig = ~panEvenly.(
		SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi) * amp * EnvGen.kr(Env.perc(0.001, releaseTime),
			1, doneAction: 2) * 0.3,
		0, // pan
		2, // width (Each signal is spread over how many channels?)
		1 // spread // How far the signals are spread from each other
	);
	Out.ar(out, sig);
}).add;
SynthDef(\reverb, { | in, out=0, room=1, damp=0.5, amp=1 |
	Out.ar(
		out,
		FreeVerb.ar(
			In.ar(in, s.options.numOutputBusChannels),
			1,
			room, damp, amp
		)
	);
}).add;
SynthDef(\bouncyBass, { | out = 0, freq = 60, gate = 1, amp = 0.1, pan=0.25 |
	var env = EnvGen.kr(Env.asr(0, 1, 0), gate, doneAction: 2);
	var bounceEnv = LPF.ar(LFPulse.ar(EnvGen.ar(Env([20, 0], [0.5]), gate)), 600);
	var modEnv = EnvGen.kr(Env([0, 1, 0], [0.2, 0.1]), gate);
	var sig = bounceEnv * SinOsc.ar(freq + SinOsc.ar(freq * 2, 0, modEnv * (freq * 10), freq)) * 0.2 * env;
	Out.ar(out, ~panEvenly.(sig * amp, pan));
}).add;