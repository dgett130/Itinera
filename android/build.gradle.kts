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
// Workaround: alcuni plugin datati (es. sqlite3_flutter_libs 0.5.0), imposti
// dai vincoli di versione su Dart 3.10.x, non dichiarano il "namespace"
// richiesto dall'Android Gradle Plugin moderno. Lo deriviamo dal package
// dell'AndroidManifest del plugin. Va registrato PRIMA di evaluationDependsOn,
// altrimenti i progetti risultano gia' valutati. Da rimuovere se si aggiornera'
// Flutter/Dart e si potranno usare le versioni recenti di questi plugin.
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension != null) {
            androidExtension.withGroovyBuilder {
                if (getProperty("namespace") == null) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val pkg = Regex("package=\"([^\"]+)\"")
                            .find(manifestFile.readText())
                            ?.groupValues?.get(1)
                        if (pkg != null) {
                            setProperty("namespace", pkg)
                        }
                    }
                }
            }
            // I plugin datati compilano le risorse con un compileSdk vecchio
            // (< 31), causando in release errori come "android:attr/lStar not
            // found". Forziamo un compileSdk moderno SOLO sulle librerie plugin,
            // lasciando invariato :app (che usa quello di Flutter).
            if (project.plugins.hasPlugin("com.android.library")) {
                androidExtension.withGroovyBuilder {
                    "compileSdkVersion"(34)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
