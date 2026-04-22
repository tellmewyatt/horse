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
SynthDef(\normalizedVocoder, { |
	amp=0.2,
	gate=1,
	freq=200,
	out=0,
	bufnum,
	pan=0,
	freqRatio=1,
	convolutionBuffer,
	oscDefect=0,
	envCurve= -4,
	reverbBus,
	reverbSend=0,
	reverbPreDelay=0
	|
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
SynthDef(\normalizedVocoderHeld, { | amp=0.2, gate=1, freq=200, out=0, bufnum, pan=0, freqRatio=1, convolutionBuffer, oscDefect=0, envCurve= -4, reverbBus, reverbSend=0, reverbPreDelay=0, attack=1, release=1 |
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
		Env.asr(attack, 1, release),
		gate,
		doneAction: 2
	);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = sig +HPF.ar(Convolution2.ar(sig, convolutionBuffer, 0, 1024) * 0.1, 100);
	sig = ~panEvenly.(
		sig * 0.5 * amp * env,
		pan
	);
	sig = LPF.ar(sig, 4000);
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
SynthDef(\crazyFall, { | out = 0, dur=1, amp=0.1, pan=0, spread=0.5, startFreq=20000, endFreq=1000 |
	var openEnv = EnvGen.kr(Env.step([1,0], [dur,0]), 1);
	var env = EnvGen.kr(Env([0,1,1,0], [0, dur, dur+1]), 1, doneAction: 2);
	var sig = StandardL.ar(Line.kr(startFreq, endFreq, dur), Rand(1.0, 1.1)) * amp * openEnv * 0.5;
	sig = [CombC.ar(sig, 1, 0.2, 1), CombC.ar(sig, 1, 0.3, 1)];
	sig = Limiter.ar(sig * env, amp);
	sig = ~panEvenly.(sig, pan, 2, spread);
	Out.ar(out, sig);
}).add;
SynthDef(\noisyCross, { | out = 0, amp = 0.2, bufnum, gate=1, minPlaybackRate=0.9, maxPlaybackRate=1.1 |
	var modulator, trig, sig, pan, env;
	env = EnvGen.kr(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	pan = LFNoise2.kr(1);
	modulator = StandardL.ar(LFNoise1.ar(0.1).range(100, 6000), 1.2);
	trig = Dust.ar(40);
	sig = GrainBuf.ar(1, trig, 0.5, bufnum, TRand.kr(minPlaybackRate, maxPlaybackRate, trig) * BufRateScale.kr(bufnum), LFNoise2.ar(0.2).range(0, 0.9));
	sig = sig * modulator + sig;
	sig = sig * amp;
	sig = DelayN.ar(sig, 0.3, Rand(0.1, 0.3 ! 4));
	sig = sig * env;
	Out.ar(
		out,
		~panEvenly.(Limiter.ar(sig, 0.5), pan, 2, 0.5)
	);
}).add;
SynthDef(\noisyCrossControlled, { | out = 0, amp = 0.2, bufnum, gate=1, pan=0, pos=0 |
	var modulator, trig, sig, env;
	env = EnvGen.kr(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	modulator = StandardL.ar(LFNoise1.ar(0.1).range(100, 6000), 1.2);
	trig = Dust.ar(40);
	sig = GrainBuf.ar(1, trig, 0.5, bufnum, TRand.kr(0.9, 1.1, trig) * BufRateScale.kr(bufnum), pos);
	sig = sig * modulator + sig;
	sig = sig * amp;
	sig = DelayN.ar(sig, 0.3, Rand(0.1, 0.3 ! 4));
	sig = sig * env;
	Out.ar(
		out,
		~panEvenly.(Limiter.ar(sig, 0.5), pan, 2, 0.5)
	);
}).add;
SynthDef(\meoCircles, { | out=0, amp=1, panRate=0.5, bufnum, playbackRate=1, gate=1, release=0.01 |
	var trig = Impulse.ar(2);
	var sig = GrainBuf.ar(1, trig, 4, bufnum, playbackRate * TRand.kr(-0.25.midiratio, 0.25.midiratio, trig), LFSaw.kr(0.2).range(0, 1)) * 4;
	var pan = LFSaw.kr(panRate).range(-1, 1) * -1;
	var env = EnvGen.kr(Env.asr(0.01, 1, release), gate, doneAction: 2);
	sig = (sig.tanh / 4) * amp;
	Out.ar(out, ~panEvenly.(
		sig * env,
		pan
	));
}).add;
SynthDef(\sinPulse, { | freq=200, gate=1, out = 0 , amp=0.1, pan=0, distortionFactor=0, panRateScale=0, release=0.01 |
	var env, sig;
	// Prevent distortion factor from being less than 0
	distortionFactor = distortionFactor.max(0).lag(2);
	env = EnvGen.kr(Env.asr(0.01, 1, release), gate, doneAction: 2);
	sig = SinOsc.ar(freq, 0) + (SinOsc.ar(freq, 0, distortionFactor).tanh);
	sig = LPF.ar(LFPulse.ar(2).range(0.5,1), 1000) * sig * amp * env;
	pan = (pan + LFSaw.ar(panRateScale * Rand(0.5,1), 0).range(0, 2)).range(-1, 1);
	Out.ar(out, ~panEvenly.(sig, pan));
}).add;
SynthDef(\sinFmHit, { | freq = 200, modIndex = 10, cmRatio=2.31, pan=0, width=2, out=0, release=2, attack=0, amp=0.1, curve= -4, modIndexCurve= -4, reverbBus, reverbAmp, gate=1  |
	var env = EnvGen.kr(Env.perc(attack, release, curve: curve), doneAction: 2);
	var sustainEnv = EnvGen.kr(Env.asr(0, 1, 0.1), gate);
	var sig;
	modIndex = EnvGen.kr(Env.perc(attack,release, curve: modIndexCurve), 1, modIndex);
	sig = ~panEvenly.(SinOsc.ar(freq + SinOsc.ar(cmRatio * freq, 0.2, modIndex * cmRatio * freq), 0.5pi, 0.5), pan, width=2);
	sig = sig * amp * env * sustainEnv;
	Out.ar(reverbBus, sig * reverbAmp);
	Out.ar(out, sig);
}).add;


// Control SynthDefs
SynthDef(\rgbHit, { | out, red=1, green=1, blue=1, attack=0.01, release=3, amp=1, curve= 0 |
	Out.kr(out, EnvGen.kr(Env.perc(attack, release, amp, curve), doneAction: 2) * [red, green, blue]);
}).add;
SynthDef(\rgbOffset, { | out, red=1, green=1, blue=1 |
	Out.kr(out, [red, green, blue])
}).add;
SynthDef(\videoHit, { | out, attack=0.01, release=3, amp=1, curve=0 |
	Out.kr(out, EnvGen.kr(Env.perc(attack, release, amp, curve), doneAction: 2));
}).add;
SynthDef(\videoOffset, { | out, level=1 |
	Out.kr(out, level)
}).add;
SynthDef(\videoControl, { | out, in, min=0, max=1 |
	var sig = In.kr(in, 1);
	sig = sig.min(max).max(min);
	ReplaceOut.kr(out, sig);
}).add;
SynthDef(\videoControl3, { | out, in, min=0, max=1 |
	var sig = In.kr(in, 3);
	//sig = sig.min(max).max(min);
	ReplaceOut.kr(out, sig);
}).add;
SynthDef(\videoSwirl3, { | out, min=0, max=1, freq=1, amp=1 |
	Out.kr(out,
		3.collect { | i |
			SinOsc.ar(freq, i / 3 * 2pi, amp)
	});
}).add;