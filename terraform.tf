provider "vsphere" {
  user           = "${var.user}"
  password       = "${var.password}"
  vsphere_server = "${var.vsphere_server}"

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "host" {
 name          = "10.42.2.97"
 datacenter_id = data.vsphere_datacenter.dc.id
}




resource "vsphere_virtual_machine" "vm" {
  name             = "${var.name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
    datacenter_id     = "${data.vsphere_datacenter.dc.id}"
   
   host_system_id       = data.vsphere_host.host.id

  num_cpus = 2
  memory   = 1024
  guest_id         = "other3xLinux64Guest"

 

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"

  }

  cdrom {
    client_device = true
  }

    ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = "http://nas.rabat.sqli.com/ubuntu20.04.ova"
    disk_provisioning         = "thin"
    ip_protocol               = "IPV4"
    ip_allocation_policy      = "STATIC_MANUAL"
    ovf_network_map = {
      "Network 1" = data.vsphere_network.network.id
      "Network 2" = data.vsphere_network.network.id
    }
  }


  vapp {
    properties = {
      user-data = "${base64encode(file("cloud-init.yml"))}"
    }
  }

 
}
