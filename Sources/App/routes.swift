import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: ExerciseController())
  try app.register(collection: UserController())
  try app.register(collection: ExerciseSessionController())
  try app.register(collection: GoalTemplateController())
  try app.register(collection: GoalController())
}
