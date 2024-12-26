ThisBuild / scalaVersion := "3.3.1"
ThisBuild / version := "0.1.0"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
.settings(
    name := "scala3-project",
    
    libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.17" % Test,

    Compile / scalaSource := baseDirectory.value / "src" / "main" / "scala",
    Test / scalaSource := baseDirectory.value / "src" / "test" / "scala"
)

