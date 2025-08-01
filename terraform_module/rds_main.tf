module "rds-db" {
    source                    = "./modules/rds"
    db_identifier             = "frappe-db"
  allocated_storage           = 20
  db_engine                   = "mariadb"
  engine_version              = "11.4.5"
  instance_class              = "db.t4g.micro"
  username                    = "root"
  db_password                 = "redhat12321"
  storage_type                = "gp2"
}
