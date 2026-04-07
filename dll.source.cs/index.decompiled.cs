using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
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
[assembly: AssemblyInformationalVersion("1.0.0+1b12f57d3984eb0863c46a7b87fce6caeccd209e")]
[assembly: AssemblyProduct("temp")]
[assembly: AssemblyTitle("temp")]
[assembly: AssemblyVersion("1.0.0.0")]
[module: RefSafetyRules(11)]
namespace SchoolModel;

public enum DisciplineStatus
{
	Active,
	Suspended,
	Expelled
}
public class Student
{
	public int Id { get; }

	public string Name { get; }

	public DisciplineStatus Status { get; private set; }

	public Student(int id, string name)
	{
		Id = id;
		Name = name;
		Status = DisciplineStatus.Active;
	}

	public void Suspend()
	{
		Status = DisciplineStatus.Suspended;
	}

	public void Expel()
	{
		Status = DisciplineStatus.Expelled;
	}

	public override string ToString()
	{
		return $"{Id:D2} - {Name} [{Status}]";
	}
}
public class ClassRoom
{
	public int ClassNumber { get; }

	public List<Student> Students { get; } = new List<Student>();

	public ClassRoom(int classNumber)
	{
		ClassNumber = classNumber;
	}

	public void AddStudent(Student s)
	{
		Students.Add(s);
	}

	public override string ToString()
	{
		return $"Class {ClassNumber}: {Students.Count} students";
	}
}
public class School
{
	public string Name { get; }

	public List<ClassRoom> Classes { get; } = new List<ClassRoom>();

	public IEnumerable<Student> AllStudents => Classes.SelectMany((ClassRoom c) => c.Students);

	public School(string name)
	{
		Name = name;
	}

	public void AddClass(ClassRoom c)
	{
		Classes.Add(c);
	}

	public override string ToString()
	{
		return $"{Name} with {Classes.Count} classes and {AllStudents.Count()} students";
	}
}
internal class Program
{
	private static void Main()
	{
		School school = new School("Detention High");
		for (int i = 1; i <= 10; i++)
		{
			ClassRoom c = new ClassRoom(i);
			school.AddClass(c);
		}
		int num = 1;
		foreach (ClassRoom @class in school.Classes)
		{
			while (@class.Students.Count < 3 && num <= 30)
			{
				@class.AddStudent(new Student(num, $"Student_{num}"));
				num++;
			}
		}
		List<Student> source = school.AllStudents.ToList();
		foreach (Student item in source.Take(5))
		{
			item.Suspend();
		}
		foreach (Student item2 in source.Skip(5).Take(3))
		{
			item2.Expel();
		}
		Console.WriteLine(school);
		Console.WriteLine();
		foreach (ClassRoom class2 in school.Classes)
		{
			Console.WriteLine(class2);
			foreach (Student student in class2.Students)
			{
				Console.WriteLine("  " + student);
			}
			Console.WriteLine();
		}
	}
}
