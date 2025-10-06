cmake_minimum_required(VERSION 3.16)
project(adilshell LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.4 COMPONENTS Quick QuickControls2 DBus REQUIRED)

qt_add_executable(adilshell
    src/main.cpp
)

qt_add_qml_module(adilshell
    URI AdilShell
    VERSION 1.0
    QML_FILES
        src/qml/Main.qml
        src/qml/QuickToggles.qml
        src/qml/AIPalette.qml
)

target_link_libraries(adilshell PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::DBus)

install(TARGETS adilshell RUNTIME DESTINATION bin)
