module.exports = {
  commitEXE: true,
  CI: true,
  
  Advanced: {
    target: "index.cpp",
    output: "Banana.exe",
    commit2: "main",
    flags: ["/O2", "/MT", "/EHsc", "index.cpp", "/Fe:build\Banana.exe", "/link", "/SUBSYSTEM:WINDOWS", "user32.lib"]
  }
};
