S.cfga({
  "defaultToCurrentScreen" : true,
  "secondsBetweenRepeat" : 0.1,
  "windowHintsIgnoreHiddenWindows" : false,
  "windowHintsSpread" : true,
  "windowHintsShowIcons" : true,
});

S.bnda({
  // Window Hints
  "esc:cmd" : S.op("hint"),

  // Switch currently doesn't work well so I'm commenting it out until I fix it.
  "tab:cmd" : S.op("switch"),

  // Grid
  "esc:ctrl" : S.op("grid")
});
