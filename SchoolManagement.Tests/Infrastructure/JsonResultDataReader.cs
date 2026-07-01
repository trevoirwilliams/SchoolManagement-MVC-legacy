using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace SchoolManagement.Tests.Infrastructure
{
    public static class JsonResultDataReader
    {
        public static T GetPropertyValue<T>(object source, string propertyName)
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }

            var property = source.GetType().GetProperty(propertyName);

            if (property == null)
            {
                throw new InvalidOperationException(
                    $"Property '{propertyName}' was not found on JSON result data type '{source.GetType().FullName}'.");
            }

            var value = property.GetValue(source, null);

            if (value == null)
            {
                return default(T);
            }

            if (value is T typedValue)
            {
                return typedValue;
            }

            return (T)Convert.ChangeType(value, typeof(T));
        }

        public static IReadOnlyList<object> ToObjectList(object data)
        {
            if (data == null)
            {
                return Array.Empty<object>();
            }

            if (data is string)
            {
                return new[] { data };
            }

            if (data is IEnumerable enumerable)
            {
                return enumerable.Cast<object>().ToList();
            }

            return new[] { data };
        }
    }
}