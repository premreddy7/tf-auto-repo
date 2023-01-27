resource "google_sql_database_instance" "master" {
  name             = "${var.app}-db"
  database_version = var.db_ver
  region           = var.region
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.default.id
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]

}


resource "google_sql_database" "database" {
  name     = "codingthunder"
  instance = google_sql_database_instance.master.name
}


resource "google_sql_user" "user" {
  name     = var.app
  instance = google_sql_database_instance.master.name
  host     = "%"
  password = random_id.default.id
}