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
    public class EnrollmentsJsonEndpointTests
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
        public async Task Enrollments_AddStudent_WhenNotAlreadyEnrolled_ReturnsSuccessJson_CurrentBaseline()
        {
            // Arrange
            int courseId;
            int studentId;

            using (var context = new SchoolManagement_DBEntities())
            {
                var token = TestDataFactory.NewToken();
                var course = TestDataFactory.AddCourse(context, token);
                var student = TestDataFactory.AddStudent(context, token);

                courseId = course.CourseId;
                studentId = student.StudentID;
            }

            using (var controller = new EnrollmentsController())
            {
                var enrollment = new Enrollment
                {
                    CourseID = courseId,
                    StudentID = studentId
                };

                // Act
                var result = await controller.AddStudent(enrollment);

                // Assert
                AssertJsonBoolean(result, "IsSuccess", true);
                AssertJsonString(result, "Message", "Student Added Successfully");

                using (var context = new SchoolManagement_DBEntities())
                {
                    var exists = context.Enrollments.Any(e =>
                        e.CourseID == courseId &&
                        e.StudentID == studentId);

                    Assert.IsTrue(exists, "Expected AddStudent to persist the new enrollment.");
                }
            }
        }

        [TestMethod]
        public async Task Enrollments_AddStudent_WhenAlreadyEnrolled_ReturnsDuplicateFailureJson_CurrentBaseline()
        {
            // Arrange
            int courseId;
            int studentId;

            using (var context = new SchoolManagement_DBEntities())
            {
                var token = TestDataFactory.NewToken();
                var course = TestDataFactory.AddCourse(context, token);
                var student = TestDataFactory.AddStudent(context, token);
                TestDataFactory.AddEnrollment(context, course, student);

                courseId = course.CourseId;
                studentId = student.StudentID;
            }

            using (var controller = new EnrollmentsController())
            {
                var duplicateEnrollment = new Enrollment
                {
                    CourseID = courseId,
                    StudentID = studentId
                };

                // Act
                var result = await controller.AddStudent(duplicateEnrollment);

                // Assert
                AssertJsonBoolean(result, "IsSuccess", false);
                AssertJsonString(result, "Message", "Student is already enrolled");
            }
        }

        [TestMethod]
        public void Enrollments_GetStudents_WhenTermMatchesFullName_ReturnsNameAndIdJson_CurrentBaseline()
        {
            // Arrange
            int expectedStudentId;
            string expectedName;
            string searchTerm;

            using (var context = new SchoolManagement_DBEntities())
            {
                var token = TestDataFactory.NewToken();
                var student = TestDataFactory.AddStudent(context, token);

                expectedStudentId = student.StudentID;
                expectedName = student.FirstName + " " + student.LastName;
                searchTerm = student.FirstName;
            }

            using (var controller = new EnrollmentsController())
            {
                // Act
                var result = controller.GetStudents(searchTerm);

                // Assert
                var items = JsonResultDataReader.ToObjectList(result.Data);

                var matchingItem = items.SingleOrDefault(item =>
                    JsonResultDataReader.GetPropertyValue<int>(item, "Id") == expectedStudentId);

                Assert.IsNotNull(matchingItem, "Expected GetStudents to return the seeded student.");

                var actualName = JsonResultDataReader.GetPropertyValue<string>(matchingItem, "Name");
                var actualId = JsonResultDataReader.GetPropertyValue<int>(matchingItem, "Id");

                Assert.AreEqual(expectedName, actualName, "Expected current JSON Name shape to be 'FirstName LastName'.");
                Assert.AreEqual(expectedStudentId, actualId, "Expected current JSON Id value to match StudentID.");
            }
        }

        private static void AssertJsonBoolean(JsonResult result, string propertyName, bool expectedValue)
        {
            Assert.IsNotNull(result, "Expected JsonResult.");
            var actualValue = JsonResultDataReader.GetPropertyValue<bool>(result.Data, propertyName);
            Assert.AreEqual(expectedValue, actualValue, $"Expected JSON property '{propertyName}' to match.");
        }

        private static void AssertJsonString(JsonResult result, string propertyName, string expectedValue)
        {
            Assert.IsNotNull(result, "Expected JsonResult.");
            var actualValue = JsonResultDataReader.GetPropertyValue<string>(result.Data, propertyName);
            Assert.AreEqual(expectedValue, actualValue, $"Expected JSON property '{propertyName}' to match.");
        }
    }
}