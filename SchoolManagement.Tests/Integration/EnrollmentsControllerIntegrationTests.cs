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
        private TestDataFactory _testData;

        [TestInitialize]
        public void Initialize()
        {
            LegacyTestDatabase.EnsureCreated();
            _testData = new TestDataFactory();
            LegacyTestDatabase.ClearGeneratedTestData(_testData.TestPrefix);
        }

        [TestCleanup]
        public void Cleanup()
        {
            LegacyTestDatabase.ClearGeneratedTestData(_testData.TestPrefix);
        }

        [TestMethod]
        public async Task Enrollments_Index_ReturnsEnrollmentsWithRelatedData_CurrentBaseline()
        {
            // Arrange
            int enrollmentId;

            using (var context = new SchoolManagement_DBEntities())
            {
                var token = _testData.NewToken();
                var course = _testData.AddCourse(context, token);
                var student = _testData.AddStudent(context, token);
                var lecturer = _testData.AddLecturer(context, token);
                var enrollment = _testData.AddEnrollment(context, course, student, lecturer);

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
                var firstToken = _testData.NewToken();
                var expectedCourse = _testData.AddCourse(context, firstToken);
                var expectedStudent = _testData.AddStudent(context, firstToken);
                var expectedEnrollment = _testData.AddEnrollment(context, expectedCourse, expectedStudent);

                var secondToken = _testData.NewToken();
                var otherCourse = _testData.AddCourse(context, secondToken);
                var otherStudent = _testData.AddStudent(context, secondToken);
                _testData.AddEnrollment(context, otherCourse, otherStudent);

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