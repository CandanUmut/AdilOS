cmake_minimum_required(VERSION 3.16)
project(adilbrowser LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.4 COMPONENTS Quick QuickControls2 WebEngineQuick REQUIRED)

qt_add_executable(adilbrowser
    src/main.cpp
)

qt_add_qml_module(adilbrowser
    URI AdilBrowser
    VERSION 1.0
    QML_FILES
        qml/Main.qml
    RESOURCES
        resources/tracker-blocklist.txt
)

target_link_libraries(adilbrowser PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::WebEngineQuick)

install(TARGETS adilbrowser RUNTIME DESTINATION bin)
