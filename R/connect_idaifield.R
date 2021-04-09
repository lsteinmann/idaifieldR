connect_idaifield <- function(serverip    = "192.168.1.199",
                              user        = "Anna Allgemeinperson",
                              pwd         = "password") {


  idaifield_connection <- sofa::Cushion$new(host = serverip,
                                            transport = "http",
                                            port = 3000,
                                            user = user,
                                            pwd = pwd)

  return(idaifield_connection)
}
