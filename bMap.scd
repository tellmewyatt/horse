~noteMap.def(\b, { | m |
	// Turns off the previously held notes if they are on
	var finalReleaseTime=20;
	var getCol5Func = { | freq, release=0.01 |
		{ | vel | Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, freq/205, \release, release]); }
	};
	var enabledRows = Set();
	var toggleGroups = ();
	var togglePrevious = { | nn, vel |
		var map = ~noteMap.noteMaps.a;
		if(map.toggleMap[nn].notNil) {
			map.onMap[nn].(vel);
		};
	};
	var getBellFunc = { | nn, freq |
		{ | vel|
			var synths;
			var row = nn.asString[0].digit;
			if(toggleGroups[nn].isNil) {
				toggleGroups[nn] = Group(s);
				synths = toggleGroups[nn];
			};
			synths = toggleGroups[nn];
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			synths;
		}
	};
	var getBellReleaseFunc = { | freq |
		{ | vel |
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
		}
	};
	var bellToggle = { | nn, freq |
		m.toggle(nn, getBellFunc.(nn, freq));
		m.toggleOff(nn, getBellReleaseFunc.(freq));
	};
	m.toggle(14, { | vel | Synth(\noisyCross, [\bufnum, ~samples.whatami, \amp, 0.4]) });
	m.toggle(15, { | vel | Synth(\sinPulse, [\freq, 200 * 7.midiratio, \distortionFactor, 2, \release, finalReleaseTime]) });
	m.toggle(16, { | vel | Synth(\sinPulse, [\freq, 100, \distortionFactor, 2, \release, finalReleaseTime]) });
	m.hit(18, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(28, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(38, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);

	});
	m.hit(48, { | vel |
		Synth(\sinFmHit, [\freq, 800, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(58, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});

	bellToggle.(58, 800);
	bellToggle.(57, 800 * -1.5.midiratio);
	bellToggle.(56, 800 * -3.75.midiratio);
	bellToggle.(53, 100);
	bellToggle.(52, 100 * -7.midiratio);
	bellToggle.(51, 100 * -12.midiratio);

	bellToggle.(63, 200 * -1.25.midiratio);
	bellToggle.(62, 200 * -2.5.midiratio);
	bellToggle.(61, 200 * -4.midiratio);
	bellToggle.(68, 800 * -2.25.midiratio);
	bellToggle.(67, 800 * -5.25.midiratio);
	bellToggle.(66, 800 * -7.midiratio);

	bellToggle.(71, 200 * 1.25.midiratio);
	bellToggle.(72, 200 * 2.5.midiratio);
	bellToggle.(73, 200 * 4.midiratio);
	bellToggle.(76, 800 * 2.25.midiratio);
	bellToggle.(77, 800 * 5.25.midiratio);
	bellToggle.(78, 800 * 7.midiratio);
	bellToggle.(81, 100);
	bellToggle.(82, 100 * 7.midiratio);
	bellToggle.(83, 100 * 12.midiratio);
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
		Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, 490/205], synths);
		Synth(\sinPulse, [\freq, 50, \pan, rrand(-1.0, 1), \distortionFactor, 20, \amp, 0.05], synths);
		synths;
	});

	// Column 9
	m.rowControl({ | row |
		var currentPulsePad = row * 10 + 9;
		var pulsePad = row * 10 + 5;
		enabledRows.add(row);
		togglePrevious.(pulsePad);
		(1..8).do { | i |
			var nn = row * 10 + i;
			nn.postln;
			if(m.current.toggleMap[nn].isNil) {
				~noteMap.colorPad(nn, m.current.getPadColor(nn));
			};
		};
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
		m.current.toggleMap.keys.do {  | key |
			m.current.onMap[key].(1);
		};
		toggleGroups.collect { | g |
			g.free;
		};
		toggleGroups = ();
	});
});