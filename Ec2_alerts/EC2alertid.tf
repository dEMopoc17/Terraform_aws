module "Ec2-id" {
    source = "./modules"
    instance_id = "mi"
    
}
module "name" {
    source = "./modules"
   instance_id = "roadbt"
}