using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Models;
using SchoolManagement.Tests.Helpers;
using System;
using System.ComponentModel.DataAnnotations;

namespace SchoolManagement.Tests.Models.MetaClasses
{
    [TestClass]
    public class MetadataAttributesBaselineTests
    {
        [TestMethod]
        public void CourseMetadata_HasExpectedValidationAttributes()
        {
            // Arrange
            var metadataType = typeof(CoursesMetadata);

            // Act
            var titleProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "Title");
            var creditsProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "Credits");
            var titleLengthAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<StringLengthAttribute>(titleProperty);
            var creditsRangeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<RangeAttribute>(creditsProperty);

            // Assert
            Assert.IsNotNull(titleLengthAttribute,
                "Baseline validation changed: CoursesMetadata.Title should keep [StringLength(50)].");
            Assert.AreEqual(50, titleLengthAttribute.MaximumLength,
                "Baseline validation changed: CoursesMetadata.Title max length should remain 50.");

            Assert.IsNotNull(creditsRangeAttribute,
                "Baseline validation changed: CoursesMetadata.Credits should keep [Range(1, 8)].");
            Assert.AreEqual("1", creditsRangeAttribute.Minimum.ToString(),
                "Baseline validation changed: CoursesMetadata.Credits minimum should remain 1.");
            Assert.AreEqual("8", creditsRangeAttribute.Maximum.ToString(),
                "Baseline validation changed: CoursesMetadata.Credits maximum should remain 8.");
        }

        [TestMethod]
        public void StudentMetadata_HasExpectedStringLengthAndDisplayAttributes()
        {
            // Arrange
            var metadataType = typeof(StudentMetadata);

            // Act
            var lastNameProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "LastName");
            var firstNameProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "FirstName");
            var middleNameProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "MiddleName");
            var enrollmentDateProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "EnrollmentDate");

            var lastNameLength = ReflectionTestHelper.GetSingleOrDefaultAttribute<StringLengthAttribute>(lastNameProperty);
            var firstNameLength = ReflectionTestHelper.GetSingleOrDefaultAttribute<StringLengthAttribute>(firstNameProperty);
            var middleNameLength = ReflectionTestHelper.GetSingleOrDefaultAttribute<StringLengthAttribute>(middleNameProperty);

            var lastNameDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(lastNameProperty);
            var firstNameDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(firstNameProperty);
            var middleNameDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(middleNameProperty);
            var enrollmentDateDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(enrollmentDateProperty);

            // Assert
            Assert.IsNotNull(lastNameLength, "Baseline validation changed: StudentMetadata.LastName should keep [StringLength(50)].");
            Assert.AreEqual(50, lastNameLength.MaximumLength, "Baseline validation changed: StudentMetadata.LastName max length should remain 50.");
            Assert.AreEqual("Last Name", lastNameDisplay.Name, "Baseline display changed: StudentMetadata.LastName display label should remain 'Last Name'.");

            Assert.IsNotNull(firstNameLength, "Baseline validation changed: StudentMetadata.FirstName should keep [StringLength(50)].");
            Assert.AreEqual(50, firstNameLength.MaximumLength, "Baseline validation changed: StudentMetadata.FirstName max length should remain 50.");
            Assert.AreEqual("First Name", firstNameDisplay.Name, "Baseline display changed: StudentMetadata.FirstName display label should remain 'First Name'.");

            Assert.IsNotNull(middleNameLength, "Baseline validation changed: StudentMetadata.MiddleName should keep [StringLength(50)].");
            Assert.AreEqual(50, middleNameLength.MaximumLength, "Baseline validation changed: StudentMetadata.MiddleName max length should remain 50.");
            Assert.AreEqual("Middle Name", middleNameDisplay.Name, "Baseline display changed: StudentMetadata.MiddleName display label should remain 'Middle Name'.");

            Assert.AreEqual("Date of Enrollment", enrollmentDateDisplay.Name,
                "Baseline display changed: StudentMetadata.EnrollmentDate display label should remain 'Date of Enrollment'.");
        }

        [TestMethod]
        public void EnrollmentMetadata_HasExpectedDisplayAttributes()
        {
            // Arrange
            var metadataType = typeof(EnrollmentMetadata);

            // Act
            var courseIdProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "CourseID");
            var studentIdProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "StudentID");
            var lecturerIdProperty = ReflectionTestHelper.GetRequiredProperty(metadataType, "LecturerId");

            var courseDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(courseIdProperty);
            var studentDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(studentIdProperty);
            var lecturerDisplay = ReflectionTestHelper.GetSingleOrDefaultAttribute<DisplayAttribute>(lecturerIdProperty);

            // Assert
            Assert.AreEqual("Course", courseDisplay.Name,
                "Baseline display changed: EnrollmentMetadata.CourseID label should remain 'Course'.");
            Assert.AreEqual("Student", studentDisplay.Name,
                "Baseline display changed: EnrollmentMetadata.StudentID label should remain 'Student'.");
            Assert.AreEqual("Lecturer", lecturerDisplay.Name,
                "Baseline display changed: EnrollmentMetadata.LecturerId label should remain 'Lecturer'.");
        }

        [TestMethod]
        [DataRow(typeof(Course), typeof(CoursesMetadata))]
        [DataRow(typeof(Student), typeof(StudentMetadata))]
        [DataRow(typeof(Enrollment), typeof(EnrollmentMetadata))]
        public void PartialModelClasses_AreMappedToExpectedMetadataTypes(Type modelType, Type expectedMetadataType)
        {
            // Arrange & Act
            var metadataTypeAttribute = ReflectionTestHelper.GetSingleOrDefaultAttribute<MetadataTypeAttribute>(modelType);

            // Assert
            Assert.IsNotNull(metadataTypeAttribute,
                "Baseline metadata mapping changed: {0} should declare [MetadataType].", modelType.Name);
            Assert.AreEqual(expectedMetadataType, metadataTypeAttribute.MetadataClassType,
                "Baseline metadata mapping changed: {0} should map to {1}.", modelType.Name, expectedMetadataType.Name);
        }
    }
}
