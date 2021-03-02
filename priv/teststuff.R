

idaifield_docs <- get_idaifield_docs(serverip = "192.168.2.21",
                                     user = "Lisa Steinmann",
                                     pwd = "hallo",
                                     projectname = "testproj")

length(idaifield_docs)



pottery <- select_by_type(idaifield_docs, type = "Pottery")




df <- convert_to_df(idaifield_docs)
