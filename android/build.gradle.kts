allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// wireguard_flutter 0.1.3 declares compileSdk 31, which is too old for
// the AndroidX dependencies resolved by the current Flutter toolchain.
subprojects {
    afterEvaluate {
        if (name == "wireguard_flutter") {
            extensions.configure<com.android.build.api.dsl.LibraryExtension> {
                compileSdk = 35
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
