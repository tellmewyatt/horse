~noteMap.def(\second, { | m |
	// Turns off the previously held notes if they are on
	var togglePrevious = { | nn, vel |
		var map = ~noteMap.noteMaps.opening;
		if(map.toggleMap[nn].notNil) {
			map.onMap[nn].(vel);
		};
	};
	~enabledRows = Set();
	m.hit(18, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(1);
		togglePrevious.(15, vel);
		~noteMap.colorAllPads;
	});
	m.hit(28, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(2);
		togglePrevious.(25, vel);
		~noteMap.colorAllPads;
	});
	m.hit(38, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(3);
		togglePrevious.(35, vel);
		~noteMap.colorAllPads;
	});
	m.hit(48, { | vel |
		Synth(\sinFmHit, [\freq, 800, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(4);
		togglePrevious.(45, vel);
		~noteMap.colorAllPads;
	});
	m.hit(58, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(5);
		togglePrevious.(55, vel);
		~noteMap.colorAllPads;
	});
	m.hit(68, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(6);
		togglePrevious.(65, vel);
		~noteMap.colorAllPads;
	});
	m.hit(78, { | vel|
		Synth(\sinFmHit, [\freq, 800 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(7);
		togglePrevious.(75, vel);
		~noteMap.colorAllPads;
	});

	m.hit(81, { | vel |
		Synth(\sinFmHit, [\freq, 100 , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 100, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(82, { | vel |
		Synth(\sinFmHit, [\freq, 150 , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 150, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(83, { | vel |
		Synth(\sinFmHit, [\freq, 200 , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 200, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(84, { | vel |
		Synth(\sinFmHit, [\freq, 200 , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 200, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(87, { | vel|
		Synth(\sinFmHit, [\freq, 800 * 1.5.midiratio, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 1.5.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(8);
		togglePrevious.(85, vel);
		~noteMap.colorAllPads;
	});
	m.hit(88, { | vel|
		Synth(\sinFmHit, [\freq, 800 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(8);
		togglePrevious.(85, vel);
		~noteMap.colorAllPads;
	});

	// Pad Colors
	m.colorPad({ | nn |
		var color;
		var alternate = nn.asString[0].digit % 2;
		if(nn + alternate % 2 == 0) {
			color = 120
		}
		{
			color = 21
		};
		if(nn % 10 == 5) {
			color = ~config.toggledPadColor;
		};
		if(~enabledRows.includes(nn.asString[0].digit)) {
			color = ~config.enabledRowColor;
		};
		color;
	});
	m.colorPadActive({ | nn |
		var color = rrand(0, 127);
		color;
	});
});