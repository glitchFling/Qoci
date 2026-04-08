module.exports = {
  commitEXE: true,
  CI: true,
  
  Advanced: {
    target: "index.cpp",
    output: "Banana.exe",
    commit2: "main",
    flags: ["/O2", "/MT", "/GL", "user32.lib", "/link", "/SUBSYSTEM:WINDOWS"]
  }
};
