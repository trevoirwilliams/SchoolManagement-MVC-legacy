using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Controllers;
using SchoolManagement.Models;
using SchoolManagement.Tests.Infrastructure;

namespace SchoolManagement.Tests.Integration
{
    [TestClass]
    public class StudentsControllerIntegrationTests
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
        public async Task Students_Details_WhenIdIsNull_ReturnsBadRequest_CurrentBaseline()
        {
            // Arrange
            using (var controller = new StudentsController())
            {
                // Act
                var result = await controller.Details(null);

                // Assert
                var statusResult = result as HttpStatusCodeResult;
                Assert.IsNotNull(statusResult, "Expected HttpStatusCodeResult for null student id.");
                Assert.AreEqual((int)HttpStatusCode.BadRequest, statusResult.StatusCode);
            }
        }

        [TestMethod]
        public async Task Students_Details_WhenStudentMissing_ReturnsHttpNotFound_CurrentBaseline()
        {
            // Arrange
            using (var controller = new StudentsController())
            {
                // Act
                var result = await controller.Details(int.MaxValue);

                // Assert
                Assert.IsInstanceOfType(
                    result,
                    typeof(HttpNotFoundResult),
                    "Expected HttpNotFoundResult when the student does not exist.");
            }
        }

        [TestMethod]
        public async Task Students_Create_WhenModelStateInvalid_ReturnsViewWithSubmittedStudent_CurrentBaseline()
        {
            // Arrange
            var student = new Student
            {
                FirstName = "AI Test Invalid",
                LastName = "AI Test Student",
                MiddleName = "AI Test Middle"
            };

            using (var controller = new StudentsController())
            {
                controller.ModelState.AddModelError("FirstName", "First name is invalid for this test.");

                // Act
                var result = await controller.Create(student);

                // Assert
                var viewResult = result as ViewResult;
                Assert.IsNotNull(viewResult, "Expected ViewResult when ModelState is invalid.");
                Assert.AreSame(student, viewResult.Model, "Expected the submitted student model to be returned.");
            }
        }

        [TestMethod]
        public async Task Students_Create_WhenModelStateIsValid_AddsStudentAndRedirectsToIndex_CurrentBaseline()
        {
            // Arrange
            var token = _testData.NewToken();

            var student = new Student
            {
                FirstName = $"AI Test First {token}",
                LastName = $"AI Test Last {token}",
                MiddleName = $"AI Test Middle {token}"
            };

            using (var controller = new StudentsController())
            {
                // Act
                var result = await controller.Create(student);

                // Assert
                var redirectResult = result as RedirectToRouteResult;
                Assert.IsNotNull(redirectResult, "Expected redirect after valid student creation.");
                Assert.AreEqual("Index", redirectResult.RouteValues["action"]);

                using (var context = new SchoolManagement_DBEntities())
                {
                    var exists = context.Students.Any(s =>
                        s.FirstName == student.FirstName &&
                        s.LastName == student.LastName &&
                        s.MiddleName == student.MiddleName);

                    Assert.IsTrue(exists, "Expected valid student creation to persist the student.");
                }
            }
        }
    }
}