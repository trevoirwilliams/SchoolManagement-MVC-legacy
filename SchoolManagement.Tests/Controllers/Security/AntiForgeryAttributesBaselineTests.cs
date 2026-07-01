using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Web.Mvc;
using SchoolManagement.Tests.Helpers;

namespace SchoolManagement.Tests.Controllers.Security
{
    [TestClass]
    public class AntiForgeryAttributesBaselineTests
    {
        [TestMethod]
        [DataRow("SchoolManagement.Controllers.CoursesController", "Create")]
        [DataRow("SchoolManagement.Controllers.CoursesController", "Edit")]
        [DataRow("SchoolManagement.Controllers.CoursesController", "DeleteConfirmed")]
        [DataRow("SchoolManagement.Controllers.StudentsController", "Create")]
        [DataRow("SchoolManagement.Controllers.StudentsController", "Edit")]
        [DataRow("SchoolManagement.Controllers.StudentsController", "DeleteConfirmed")]
        [DataRow("SchoolManagement.Controllers.LecturersController", "Create")]
        [DataRow("SchoolManagement.Controllers.LecturersController", "Edit")]
        [DataRow("SchoolManagement.Controllers.LecturersController", "DeleteConfirmed")]
        [DataRow("SchoolManagement.Controllers.EnrollmentsController", "Create")]
        [DataRow("SchoolManagement.Controllers.EnrollmentsController", "Edit")]
        [DataRow("SchoolManagement.Controllers.EnrollmentsController", "DeleteConfirmed")]
        public void StandardCrudPostActions_HaveValidateAntiForgeryToken(string controllerTypeName, string methodName)
        {
            // Arrange
            var controllerType = ReflectionTestHelper.GetApplicationType(controllerTypeName);

            // Act
            var actionMethod = ReflectionTestHelper.GetHttpPostActionMethod(controllerType, methodName);
            var antiForgeryAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<ValidateAntiForgeryTokenAttribute>(actionMethod);

            // Assert
            Assert.IsNotNull(antiForgeryAttribute,
                $"Baseline security behavior changed: Expected [ValidateAntiForgeryToken] on {controllerType.Name}.{methodName} POST action.");
        }
    }
}
