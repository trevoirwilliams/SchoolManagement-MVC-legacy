using System;
using SchoolManagement.Models;

namespace SchoolManagement.Tests.Infrastructure
{
    public sealed class TestDataFactory
    {
        public TestDataFactory()
            : this("AI Test " + Guid.NewGuid().ToString("N").Substring(0, 8))
        {
        }

        public TestDataFactory(string testPrefix)
        {
            if (string.IsNullOrWhiteSpace(testPrefix))
            {
                throw new ArgumentException("A test data prefix is required.", nameof(testPrefix));
            }

            TestPrefix = testPrefix;
        }

        public string TestPrefix { get; }

        public string NewToken()
        {
            return Guid.NewGuid().ToString("N").Substring(0, 8);
        }

        public Course AddCourse(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var course = new Course
            {
                Title = $"{TestPrefix} Course {token}",
                Credits = 3
            };

            context.Courses.Add(course);
            context.SaveChanges();

            return course;
        }

        public Student AddStudent(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var student = new Student
            {
                FirstName = $"{TestPrefix} First {token}",
                LastName = $"{TestPrefix} Last {token}",
                MiddleName = "Middle",
                EnrollmentDate = new DateTime(2024, 9, 1)
            };

            context.Students.Add(student);
            context.SaveChanges();

            return student;
        }

        public Lecturer AddLecturer(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var lecturer = new Lecturer
            {
                First_Name = $"{TestPrefix} Lecturer {token}",
                Last_Name = $"{TestPrefix} Faculty {token}"
            };

            context.Lecturers.Add(lecturer);
            context.SaveChanges();

            return lecturer;
        }

        public Enrollment AddEnrollment(
            SchoolManagement_DBEntities context,
            Course course,
            Student student,
            Lecturer lecturer = null)
        {
            if (course == null)
            {
                throw new ArgumentNullException(nameof(course));
            }

            if (student == null)
            {
                throw new ArgumentNullException(nameof(student));
            }

            if (course.CourseId <= 0)
            {
                throw new InvalidOperationException("The course must be saved before creating an enrollment.");
            }

            if (student.StudentID <= 0)
            {
                throw new InvalidOperationException("The student must be saved before creating an enrollment.");
            }

            if (lecturer != null && lecturer.Id <= 0)
            {
                throw new InvalidOperationException("The lecturer must be saved before creating an enrollment.");
            }

            var enrollment = new Enrollment
            {
                CourseID = course.CourseId,
                StudentID = student.StudentID,
                LecturerId = lecturer?.Id,
                Grade = 3.25m
            };

            context.Enrollments.Add(enrollment);
            context.SaveChanges();

            return enrollment;
        }
    }
}