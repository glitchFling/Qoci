using System;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.Versioning;

[assembly: CompilationRelaxations(8)]
[assembly: RuntimeCompatibility(WrapNonExceptionThrows = true)]
[assembly: Debuggable(DebuggableAttribute.DebuggingModes.IgnoreSymbolStoreSequencePoints)]
[assembly: TargetFramework(".NETCoreApp,Version=v10.0", FrameworkDisplayName = ".NET 10.0")]
[assembly: AssemblyCompany("temp")]
[assembly: AssemblyConfiguration("Release")]
[assembly: AssemblyFileVersion("1.0.0.0")]
[assembly: AssemblyInformationalVersion("1.0.0+80924448e9b8bbf9f640b0bc577b326050bf3ed7")]
[assembly: AssemblyProduct("temp")]
[assembly: AssemblyTitle("temp")]
[assembly: AssemblyVersion("1.0.0.0")]
[module: RefSafetyRules(11)]
internal class Program
{
	private static void Main()
	{
		Console.WriteLine("If you see this, the CI Worked.");
	}
}
