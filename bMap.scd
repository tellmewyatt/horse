~noteMap.def(\b, { | m |
	// Turns off the previously held notes if they are on
	var finalReleaseTime=20;
	var maxAmp = 0.15;
	var plateVerbAmp = 1;
	var getCol5Func = { | freq, release=0.01 |
		{ | vel | Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, freq/205, \release, release, \amp, 0.5]); }
	};
	var orangeRows = Set();
	var enabledRows = Set();
	var toggleGroups = ();
	var togglePrevious = { | nn, vel |
		var map = ~noteMap.noteMaps.a;
		if(map.toggleMap[nn].notNil) {
			map.onMap[nn].(vel);
			map.toggleMap.collect { | synth |
				synth.set(\distortionFactor, ~getDistortionFactor.(map.toggleMap.size));
			};
		};
	};
	var getBellFunc = { | nn, freq |
		{ | vel|
			var synths;
			var row = nn.asString[0].digit;
			var amp = vel * maxAmp * freq.expexp(100, 1000, 3.0, 1.0);
			freq.postln;
			amp.postln;
			if(toggleGroups[nn].isNil) {
				toggleGroups[nn] = Group(~parGroup);
				synths = toggleGroups[nn];
			};
			synths = toggleGroups[nn];
			Synth(\sinFmHit, [\freq, freq, \amp, amp, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp], synths);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, amp, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp], synths);
			synths;
		}
	};
	var getBellReleaseFunc = { | freq |
		{ | vel |
			Synth(\sinFmHit, [\freq, freq, \amp, maxAmp * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, maxAmp * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
		}
	};
	var bellToggle = { | nn, freq |
		m.toggle(nn, getBellFunc.(nn, freq));
		m.toggleOff(nn, getBellReleaseFunc.(freq));
	};
	/*var centerHit = { | nn, freq |
		m.hit(nn, { | vel |
			orangeRows = orangeRows.add( nn.asString[0].digit);
			(1..8).do { | i |
				colorRow.(i);
			};
			Synth(\sinFmHit, [\freq, freq, \amp, maxAmp * vel, \cmRatio, 2.31, \modIndex,2, \release, 20, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
			Synth(\sinFmHit, [\freq, freq * rrand(-0.25, 0.25).midiratio, \amp, maxAmp * vel, \cmRatio, 2.31, \modIndex,2, \release, 10, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
			Synth(\sinFmHit, [\freq, freq * 2, \amp, maxAmp * vel, \cmRatio, 2.31, \modIndex,2, \release, 20, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
			Synth(\sinFmHit, [\freq, freq * rrand(-0.25, 0.25).midiratio * 2, \amp, maxAmp * vel, \cmRatio, 2.31, \modIndex,2, \release, 10, \pan, rrand(-1.0, 1), \reverbBus, ~busses.plateVerb, \reverbAmp, plateVerbAmp]);
		});
	};*/
	var centerHit = { | nn |
		m.hit(nn, { | vel |
			orangeRows = orangeRows.add( nn.asString[0].digit);
			(1..8).do { | i |
				colorRow.(i);
			};
			Synth(\crazyFall, [\dur, 10, \amp, 0.1 * vel, \pan, rrand(-1.0, 1), \startFreq, s.sampleRate]);
		})
	};
	var colorRow = { | row |
		(1..8).do { | i |
			var nn = row * 10 + i;
			if(m.current.toggleMap[nn].isNil) {
				~noteMap.colorPad(nn, m.current.getPadColor(nn));
			};
		};
	};
	m.toggle(14, { | vel |
		orangeRows = orangeRows.add(1);
		Synth(\sinPulse, [\freq, 200 * 7.midiratio, \distortionFactor, 2, \release, finalReleaseTime]);

	});
	m.toggle(15, { | vel |
		orangeRows = orangeRows.add(1);
		Synth(\sinPulse, [\freq, 100, \distortionFactor, 2, \release, finalReleaseTime]);

	});
	m.hit(18, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	bellToggle.(13, 200);
	bellToggle.(12, 200 * -7.midiratio);
	bellToggle.(11, 200 * -12.midiratio);

	bellToggle.(18, 600);
	bellToggle.(17, 600 * -1.5.midiratio);
	bellToggle.(16, 600 * -3.75.midiratio);

	bellToggle.(23, 300 * -1.25.midiratio);
	bellToggle.(22, 300 * -2.5.midiratio);
	bellToggle.(21, 300 * -4.midiratio);
	bellToggle.(28, 600 * -2.25.midiratio);
	bellToggle.(27, 600 * -5.25.midiratio);
	bellToggle.(26, 600 * -7.midiratio);
	centerHit.(24, 200 * -5.midiratio);
	centerHit.(25, 100 * -5.midiratio);
	bellToggle.(31, 300 * 1.25.midiratio);
	bellToggle.(32, 300 * 2.5.midiratio);
	bellToggle.(33, 300 * 4.midiratio);
	centerHit.(34, 200 * -5.midiratio);
	centerHit.(35, 100 * -5.midiratio);
	bellToggle.(36, 600 * 2.25.midiratio);
	bellToggle.(37, 600 * 5.25.midiratio);
	bellToggle.(38, 600 * 7.midiratio);
	bellToggle.(41, 200);
	bellToggle.(42, 200 * 7.midiratio);
	bellToggle.(43, 200 * 12.midiratio);
	centerHit.(44, 200 * -4.midiratio);
	centerHit.(45, 100 * -4.midiratio);
	bellToggle.(46, 600);
	bellToggle.(47, 600 * 1.5.midiratio);
	bellToggle.(48, 600 * 3.75.midiratio);
	m.hit(58, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});

	bellToggle.(58, 800);
	bellToggle.(57, 800 * -1.5.midiratio);
	bellToggle.(56, 800 * -3.75.midiratio);
	centerHit.(54, 200 * -2.midiratio);
	centerHit.(55, 100 * -2.midiratio);
	bellToggle.(53, 100);
	bellToggle.(52, 100 * -7.midiratio);
	bellToggle.(51, 100 * -12.midiratio);

	bellToggle.(63, 200 * -1.25.midiratio);
	bellToggle.(62, 200 * -2.5.midiratio);
	bellToggle.(61, 200 * -4.midiratio);
	centerHit.(64, 200 * 2.midiratio);
	centerHit.(65, 100 * 2.midiratio);
	bellToggle.(68, 800 * -2.25.midiratio);
	bellToggle.(67, 800 * -5.25.midiratio);
	bellToggle.(66, 800 * -7.midiratio);

	bellToggle.(71, 200 * 1.25.midiratio);
	bellToggle.(72, 200 * 2.5.midiratio);
	bellToggle.(73, 200 * 4.midiratio);
	centerHit.(74, 200 * 4.midiratio);
	centerHit.(75, 100 * 4.midiratio);
	bellToggle.(76, 800 * 2.25.midiratio);
	bellToggle.(77, 800 * 5.25.midiratio);
	bellToggle.(78, 800 * 7.midiratio);


	bellToggle.(81, 100);
	bellToggle.(82, 100 * 7.midiratio);
	bellToggle.(83, 100 * 12.midiratio);
	centerHit.(84, 200);
	centerHit.(85, 100);
	bellToggle.(86, 800);
	bellToggle.(87, 800 * 1.5.midiratio);
	bellToggle.(88, 800 * 3.75.midiratio);

	// Column 9 toggles meos
	m.toggle(19, { | vel |
		// Set the final release time
		getCol5Func.(200, finalReleaseTime).(vel);
	});
	m.toggle(29, getCol5Func.(300));
	m.toggle(39, getCol5Func.(350));
	m.toggle(49, getCol5Func.(266));
	m.toggle(59, getCol5Func.(295));
	m.toggle(69, getCol5Func.(400));
	m.toggle(79, getCol5Func.(420));
	m.toggle(89, { | vel, current |
		var nn=89;
		var synths;
		if(toggleGroups[nn].isNil) {
			toggleGroups[nn] = Group(s);
			synths = toggleGroups[nn];
		};
		synths = toggleGroups[nn];
		Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, 490/205, \amp, 0.5], synths);
		Synth(\sinPulse, [\freq, 50, \pan, rrand(-1.0, 1), \distortionFactor, 5, \amp, 0.01], synths);
		synths;
	});

	// Column 9
	m.rowControl({ | row |
		var currentPulsePad = row * 10 + 9;
		var pulsePad = row * 10 + 5;
		enabledRows.add(row);
		(enabledRows.size / 8).postln;
		~busses.video.xfade.set(enabledRows.size / 8);
		if(orangeRows.includes(row)) {
			orangeRows.remove(row);
		};
		togglePrevious.(pulsePad);
		colorRow.(row);
		m.current.onMap[currentPulsePad].(1);
	});
	// Pad Colors
	m.colorPad({ | nn |
		var color;
		var alternate = nn.asString[0].digit % 2;
		var prevMap = ~noteMap.noteMaps.a;
		if(nn + alternate % 2 == 0) {
			color = 120
		}
		{
			color = 21
		};
		if(enabledRows.includes(nn.asString[0].digit)) {
			color = ~config.enabledRowColor;
		};
		if(orangeRows.includes(nn.asString[0].digit)) {
			color = ~config.orangeRowColor;
		};
		if(prevMap.toggleMap[nn].notNil) {
			color = ~config.toggledPadColor;
		};
		color;
	});
	m.colorPadActive({ | nn |
		var color = rrand(0, 127);
		if(m.current.toggleMap[nn].notNil) {
			color = ~config.toggledPadColor;
		};
		color;
	});
	// Callback to reset this to opening
	m.onReset({
		enabledRows = Set();
		orangeRows = Set();
		m.current.toggleMap.keys.do {  | key |
			m.current.onMap[key].(1);
		};
		toggleGroups.collect { | g |
			g.free;
		};
		toggleGroups = ();
	});
});