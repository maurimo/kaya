add_subdirectory(ext)

install(FILES kaya.notifyrc DESTINATION ${DATA_INSTALL_DIR}/kaya)
install(FILES kaya.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES kayaui.rc DESTINATION  ${DATA_INSTALL_DIR}/kaya)
