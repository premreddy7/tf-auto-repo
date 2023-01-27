provider "google" {
  region  = var.region
  project = var.project
}

resource "google_compute_instance_template" "template" {
  name_prefix = "${var.app}-template"

  machine_type = var.machine_type
  region       = var.region

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }

  #metadata_startup_script = file("startup.sh")
  metadata_startup_script = <<EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools -y 
  sudo apt install python3-pip -y
  pip3 install flask
  pip3 install wheel
  pip3 install gunicorn flask
  pip3 install flask_sqlalchemy
  sudo apt-get install python3-mysqldb -y
  cd /opt && sudo git clone https://github.com/operator670/blogapp.git
  cd blogapp/blogapp
  sudo sed -i "s~app.config\[\"SQLALCHEMY_DATABASE_URI\"\]=.*~app.config\[\"SQLALCHEMY_DATABASE_URI\"\]=\"mysql+mysqldb://${var.app}:${random_id.default.id}@${google_sql_database_instance.master.ip_address.0.ip_address}:3306/codingthunder?unix_socket=/cloudsql/${google_sql_database_instance.master.connection_name}\"~g" __init__.py
  sudo nohup python3 __init__.py  &> web.log &
  EOF

  disk {
    disk_type    = "pd-standard"
    source_image = "ubuntu-1804-bionic-v20230112"
    disk_size_gb = "20"
  }
}

resource "google_compute_instance_group_manager" "mig" {
  name               = "${var.app}-mig"
  base_instance_name = "${var.app}-instance"
  zone               = "${var.region}-a"
  version {
    instance_template = google_compute_instance_template.template.self_link
  }
  named_port {
    name = "http"
    port = 80
  }
  target_size        = var.target_size
  wait_for_instances = true

  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "random_id" "default" {
  byte_length = 8
}

