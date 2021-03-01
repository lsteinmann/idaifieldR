

select_by_type <- function(idaifield_docs, type = "Layer") {

  uid_type_list <- get_uid_type_list(idaifield_docs)
  typeindex <- grep(type, uid_type_list$type)

  selected_docs <- idaifield_docs[typeindex]

  return(selected_docs)
}
