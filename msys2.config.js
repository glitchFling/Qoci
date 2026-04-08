module.exports = {
  commitEXE: true,
  CI: true,
  
  Advanced: {
    target: "index.cpp",
    output: "Banana.exe",
    commit2: "main",
    flags: ["index.cpp", "/Fe:build\Banana.exe", "/O2", "/MT", "/GL", "/link", "/LTCG", "/SUBSYSTEM:WINDOWS", "user32.lib"]
  }
};
