module.exports = {
  commitEXE: false,
  CI: true,

  Advanced: {
    target: "index.cpp",
    output: "Banana.exe",
    commit2: "main",

    // ONLY compiler flags here
    flags: [
      "/O2",
      "/MT",
      "/EHsc"
    ],

    // ONLY linker flags here
    linkflags: [
      "/SUBSYSTEM:WINDOWS",
      "user32.lib"
    ]
  }
};
