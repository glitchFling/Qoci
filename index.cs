using System;
using System.Collections.Generic;
using System.Linq;

namespace SchoolModel
{
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

        public void Suspend() => Status = DisciplineStatus.Suspended;
        public void Expel() => Status = DisciplineStatus.Expelled;

        public override string ToString() => $"{Id:D2} - {Name} [{Status}]";
    }

    public class ClassRoom
    {
        public int ClassNumber { get; }
        public List<Student> Students { get; } = new List<Student>();

        public ClassRoom(int classNumber)
        {
            ClassNumber = classNumber;
        }

        public void AddStudent(Student s) => Students.Add(s);

        public override string ToString() =>
            $"Class {ClassNumber}: {Students.Count} students";
    }

    public class School
    {
        public string Name { get; }
        public List<ClassRoom> Classes { get; } = new List<ClassRoom>();

        public School(string name)
        {
            Name = name;
        }

        public void AddClass(ClassRoom c) => Classes.Add(c);

        public IEnumerable<Student> AllStudents =>
            Classes.SelectMany(c => c.Students);

        public override string ToString() =>
            $"{Name} with {Classes.Count} classes and {AllStudents.Count()} students";
    }

    internal class Program
    {
        private static void Main()
        {
            var school = new School("Detention High");

            // Create 10 classes
            for (int i = 1; i <= 10; i++)
            {
                var cls = new ClassRoom(i);
                school.AddClass(cls);
            }

            // Create 30 students and distribute across classes
            int studentId = 1;
            foreach (var cls in school.Classes)
            {
                while (cls.Students.Count < 3 && studentId <= 30)
                {
                    cls.AddStudent(new Student(studentId, $"Student_{studentId}"));
                    studentId++;
                }
            }

            // Apply discipline: some suspended, some expelled
            var all = school.AllStudents.ToList();

            // First 5 suspended
            foreach (var s in all.Take(5))
                s.Suspend();

            // Next 3 expelled
            foreach (var s in all.Skip(5).Take(3))
                s.Expel();

            Console.WriteLine(school);
            Console.WriteLine();

            foreach (var cls in school.Classes)
            {
                Console.WriteLine(cls);
                foreach (var s in cls.Students)
                    Console.WriteLine("  " + s);
                Console.WriteLine();
            }
        }
    }
}
