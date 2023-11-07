module "Ec2-id" {
    source = "./modules"
    instance_id = "mi"
    threshold = "75"
    
}
module "name" {
    source = "./modules"
   instance_id = "roadbt"
   threshold = "85"
}