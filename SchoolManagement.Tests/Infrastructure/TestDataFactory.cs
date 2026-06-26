using System;
using SchoolManagement.Models;

namespace SchoolManagement.Tests.Infrastructure
{
    public static class TestDataFactory
    {
        public static string NewToken()
        {
            return Guid.NewGuid().ToString("N").Substring(0, 8);
        }

        public static Course AddCourse(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var course = new Course
            {
                Title = $"AI Test Course {token}",
                Credits = 3
            };

            context.Courses.Add(course);
            context.SaveChanges();

            return course;
        }

        public static Student AddStudent(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var student = new Student
            {
                FirstName = $"AI Test First {token}",
                LastName = $"AI Test Last {token}",
                MiddleName = "Middle",
                EnrollmentDate = new DateTime(2024, 9, 1)
            };

            context.Students.Add(student);
            context.SaveChanges();

            return student;
        }

        public static Lecturer AddLecturer(SchoolManagement_DBEntities context, string token = null)
        {
            token = token ?? NewToken();

            var lecturer = new Lecturer
            {
                First_Name = $"AI Test Lecturer {token}",
                Last_Name = $"AI Test Faculty {token}"
            };

            context.Lecturers.Add(lecturer);
            context.SaveChanges();

            return lecturer;
        }

        public static Enrollment AddEnrollment(
            SchoolManagement_DBEntities context,
            Course course,
            Student student,
            Lecturer lecturer = null)
        {
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