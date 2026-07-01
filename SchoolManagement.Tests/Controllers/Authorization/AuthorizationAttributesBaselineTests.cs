using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Web.Mvc;
using SchoolManagement.Tests.Helpers;

namespace SchoolManagement.Tests.Controllers.Authorization
{
    [TestClass]
    public class AuthorizationAttributesBaselineTests
    {
        [TestMethod]
        public void CoursesController_HasClassLevelAuthorizeAttribute()
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType("SchoolManagement.Controllers.CoursesController");

            // Act
            var authorizeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<AuthorizeAttribute>(controllerType);

            // Assert
            Assert.IsNotNull(authorizeAttribute,
                "Baseline behavior changed: CoursesController is expected to have [Authorize] at class-level.");
            Assert.AreEqual(string.Empty, authorizeAttribute.Roles,
                "Baseline behavior changed: CoursesController [Authorize] should not restrict to a specific role.");
        }

        [TestMethod]
        public void StudentsController_HasClassLevelAuthorizeAttribute_WithTeacherRole()
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType("SchoolManagement.Controllers.StudentsController");

            // Act
            var authorizeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<AuthorizeAttribute>(controllerType);

            // Assert
            Assert.IsNotNull(authorizeAttribute,
                "Baseline behavior changed: StudentsController is expected to have [Authorize] at class-level.");
            Assert.AreEqual("Teacher", authorizeAttribute.Roles,
                "Baseline behavior changed: StudentsController [Authorize] should require the Teacher role.");
        }

        [TestMethod]
        public void StudentsController_Index_HasAllowAnonymousAttribute()
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType("SchoolManagement.Controllers.StudentsController");
            var indexMethod = controllerType.GetMethod("Index", Type.EmptyTypes);
            Assert.IsNotNull(indexMethod,
                "Baseline behavior changed: Expected StudentsController.Index() action to exist.");

            // Act
            var allowAnonymousAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<AllowAnonymousAttribute>(indexMethod);

            // Assert
            Assert.IsNotNull(allowAnonymousAttribute,
                "Current baseline behavior changed: StudentsController.Index is expected to explicitly allow anonymous access.");
        }

        [TestMethod]
        public void LecturersController_CurrentBaselineRisk_HasNoClassLevelAuthorizeAttribute()
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType("SchoolManagement.Controllers.LecturersController");

            // Act
            var authorizeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<AuthorizeAttribute>(controllerType);

            // Assert
            Assert.IsNull(authorizeAttribute,
                "CurrentBaselineRisk: LecturersController currently has no class-level [Authorize]. Any change should be intentional and reviewed.");
        }

        [TestMethod]
        public void EnrollmentsController_CurrentBaselineRisk_HasNoClassLevelAuthorizeAttribute()
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType("SchoolManagement.Controllers.EnrollmentsController");

            // Act
            var authorizeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<AuthorizeAttribute>(controllerType);

            // Assert
            Assert.IsNull(authorizeAttribute,
                "CurrentBaselineRisk: EnrollmentsController currently has no class-level [Authorize]. Any change should be intentional and reviewed.");
        }
    }
}
