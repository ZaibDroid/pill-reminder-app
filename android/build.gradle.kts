allprojects {
    repositories {
        google()
        mavenCentral()
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
    fun configureAndroidExtension(project: Project) {
        val androidExt = project.extensions.findByName("android") ?: return
        
        // 1. Set compileSdk to 36
        androidExt.javaClass.methods.forEach { method ->
            if (method.name in listOf("setCompileSdk", "setCompileSdkVersion", "compileSdkVersion") && method.parameterCount == 1) {
                try {
                    when (method.parameterTypes[0]) {
                        Int::class.javaPrimitiveType -> method.invoke(androidExt, 36)
                        java.lang.Integer::class.java -> method.invoke(androidExt, Integer.valueOf(36))
                        String::class.java -> method.invoke(androidExt, "android-36")
                    }
                } catch (_: Exception) {}
            }
        }

        // 2. Set namespace if missing
        try {
            val getNamespaceMethod = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
            val currentNamespace = getNamespaceMethod?.invoke(androidExt)
            if (currentNamespace == null) {
                val setNamespaceMethod = androidExt.javaClass.methods.firstOrNull {
                    it.name == "setNamespace" && it.parameterCount == 1 && it.parameterTypes[0] == String::class.java
                }
                val targetNamespace = if (project.name == "isar_flutter_libs") {
                    "dev.isar.isar_flutter_libs"
                } else {
                    "com.example.${project.name.replace("-", "_")}"
                }
                setNamespaceMethod?.invoke(androidExt, targetNamespace)
            }
        } catch (_: Exception) {}
    }

    plugins.withId("com.android.library") {
        configureAndroidExtension(project)
    }

    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            configureAndroidExtension(project)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
