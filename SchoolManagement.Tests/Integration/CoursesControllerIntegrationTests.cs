using System.Linq;
using System.Net;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Controllers;
using SchoolManagement.Models;
using SchoolManagement.Tests.Infrastructure;

namespace SchoolManagement.Tests.Integration
{
    [TestClass]
    public class CoursesControllerIntegrationTests
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
        public void Courses_Details_WhenIdIsNull_ReturnsBadRequest_CurrentBaseline()
        {
            // Arrange
            using (var controller = new CoursesController())
            {
                // Act
                var result = controller.Details(null);

                // Assert
                var statusResult = result as HttpStatusCodeResult;
                Assert.IsNotNull(statusResult, "Expected HttpStatusCodeResult for null course id.");
                Assert.AreEqual((int)HttpStatusCode.BadRequest, statusResult.StatusCode);
            }
        }

        [TestMethod]
        public void Courses_Details_WhenCourseMissing_ReturnsHttpNotFound_CurrentBaseline()
        {
            // Arrange
            using (var controller = new CoursesController())
            {
                // Act
                var result = controller.Details(int.MaxValue);

                // Assert
                Assert.IsInstanceOfType(
                    result,
                    typeof(HttpNotFoundResult),
                    "Expected HttpNotFoundResult when the course does not exist.");
            }
        }

        [TestMethod]
        public void Courses_Create_WhenModelStateInvalid_ReturnsViewWithSubmittedCourse_CurrentBaseline()
        {
            // Arrange
            var course = new Course
            {
                Title = "AI Test Invalid Course",
                Credits = 3
            };

            using (var controller = new CoursesController())
            {
                controller.ModelState.AddModelError("Title", "Title is required for this test.");

                // Act
                var result = controller.Create(course);

                // Assert
                var viewResult = result as ViewResult;
                Assert.IsNotNull(viewResult, "Expected ViewResult when ModelState is invalid.");
                Assert.AreSame(course, viewResult.Model, "Expected the submitted course model to be returned.");
            }
        }

        [TestMethod]
        public void Courses_Create_WhenModelStateIsValid_AddsCourseAndRedirectsToIndex_CurrentBaseline()
        {
            // Arrange
            var token = TestDataFactory.NewToken();

            var course = new Course
            {
                Title = $"AI Test Course {token}",
                Credits = 3
            };

            using (var controller = new CoursesController())
            {
                // Act
                var result = controller.Create(course);

                // Assert
                var redirectResult = result as RedirectToRouteResult;
                Assert.IsNotNull(redirectResult, "Expected redirect after valid course creation.");
                Assert.AreEqual("Index", redirectResult.RouteValues["action"]);

                using (var context = new SchoolManagement_DBEntities())
                {
                    var exists = context.Courses.Any(c => c.Title == course.Title);
                    Assert.IsTrue(exists, "Expected valid course creation to persist the course.");
                }
            }
        }
    }
}