The AI should identify the default MVC route:

```text
{controller}/{action}/{id}
```

The route is configured in `RouteConfig` with the default controller/action/id pattern.

Expected route/action mapping:

| User action              | HTTP / MVC route               | Controller action              |
| ------------------------ | ------------------------------ | ------------------------------ |
| List courses             | `/Courses` or `/Courses/Index` | `Index()`                      |
| View one course          | `/Courses/Details/{id}`        | `Details(int? id)`             |
| Open create form         | `/Courses/Create`              | `Create()` GET                 |
| Submit create form       | `/Courses/Create`              | `Create(Course course)` POST   |
| Open edit form           | `/Courses/Edit/{id}`           | `Edit(int? id)` GET            |
| Submit edit form         | `/Courses/Edit`                | `Edit(Course course)` POST     |
| Open delete confirmation | `/Courses/Delete/{id}`         | `Delete(int? id)` GET          |
| Confirm delete           | `/Courses/Delete`              | `DeleteConfirmed(int id)` POST |
