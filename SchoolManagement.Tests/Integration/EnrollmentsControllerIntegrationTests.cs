using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Controllers;
using SchoolManagement.Models;
using SchoolManagement.Tests.Infrastructure;

namespace SchoolManagement.Tests.Integration
{
    [TestClass]
    public class EnrollmentsControllerIntegrationTests
    {
        [TestInitialize]
        public void Initialize()
        {
            LegacyTestDatabase.EnsureCreated();
            LegacyTestDatabase.ClearGeneratedTestData();
        }

        [TestCleanup]
        public void Cleanup()
        {
            LegacyTestDatabase.ClearGeneratedTestData();
        }

        [TestMethod]
        public async Task Enrollments_Index_ReturnsEnrollmentsWithRelatedData_CurrentBaseline()
        {
            // Arrange
            int enrollmentId;

            using (var context = new SchoolManagement_DBEntities())
            {
                var token = TestDataFactory.NewToken();
                var course = TestDataFactory.AddCourse(context, token);
                var student = TestDataFactory.AddStudent(context, token);
                var lecturer = TestDataFactory.AddLecturer(context, token);
                var enrollment = TestDataFactory.AddEnrollment(context, course, student, lecturer);

                enrollmentId = enrollment.EnrollmentID;
            }

            using (var controller = new EnrollmentsController())
            {
                // Act
                var result = await controller.Index();

                // Assert
                var viewResult = result as ViewResult;
                Assert.IsNotNull(viewResult, "Expected ViewResult from EnrollmentsController.Index.");

                var model = ((IEnumerable<Enrollment>)viewResult.Model).ToList();
                var matchingEnrollment = model.SingleOrDefault(e => e.EnrollmentID == enrollmentId);

                Assert.IsNotNull(matchingEnrollment, "Expected the created enrollment to be returned by Index.");
                Assert.IsNotNull(matchingEnrollment.Course, "Expected Course navigation data to be loaded.");
                Assert.IsNotNull(matchingEnrollment.Student, "Expected Student navigation data to be loaded.");
                Assert.IsNotNull(matchingEnrollment.Lecturer, "Expected Lecturer navigation data to be loaded when LecturerId is present.");
            }
        }

        [TestMethod]
        public void Enrollments_Partial_WhenCourseIdProvided_FiltersByCourse_CurrentBaseline()
        {
            // Arrange
            int expectedCourseId;
            int expectedEnrollmentId;

            using (var context = new SchoolManagement_DBEntities())
            {
                var firstToken = TestDataFactory.NewToken();
                var expectedCourse = TestDataFactory.AddCourse(context, firstToken);
                var expectedStudent = TestDataFactory.AddStudent(context, firstToken);
                var expectedEnrollment = TestDataFactory.AddEnrollment(context, expectedCourse, expectedStudent);

                var secondToken = TestDataFactory.NewToken();
                var otherCourse = TestDataFactory.AddCourse(context, secondToken);
                var otherStudent = TestDataFactory.AddStudent(context, secondToken);
                TestDataFactory.AddEnrollment(context, otherCourse, otherStudent);

                expectedCourseId = expectedCourse.CourseId;
                expectedEnrollmentId = expectedEnrollment.EnrollmentID;
            }

            using (var controller = new EnrollmentsController())
            {
                // Act
                var result = controller._enrollmentPartial(expectedCourseId);

                // Assert
                Assert.IsNotNull(result, "Expected PartialViewResult from _enrollmentPartial.");

                var model = ((IEnumerable<Enrollment>)result.Model).ToList();

                Assert.IsTrue(
                    model.Any(e => e.EnrollmentID == expectedEnrollmentId),
                    "Expected the enrollment for the requested course to be present.");

                Assert.IsTrue(
                    model.All(e => e.CourseID == expectedCourseId),
                    "Expected _enrollmentPartial to return only enrollments for the requested course.");
            }
        }
    }
}