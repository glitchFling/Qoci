module.exports = {
  commitEXE: true,
  CI: false,

  Advanced: {
    target: "index.cpp",
    output: "Banana.exe",
    commit2: "main",
    flags: ["-O2", "-static", "-s", "-flto"]
  }
};
