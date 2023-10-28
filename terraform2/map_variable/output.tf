output userdata {
    value = "My name is Bhuvneshwar and age is ${lookup(var.userage, "${var.username}")}"
}