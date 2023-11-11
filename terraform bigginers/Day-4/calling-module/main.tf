module "mymodule" {
  source = "C:/Users/SivaNagaRajuVeeranki/Downloads/before kyndryl os installation/courses/terraform/terraform bigginers/Day-4/Terraform-modules"
  size = "Standard_F1"
} 

output "MyPublicIPwhileCalling" {
  value = module.mymodule.MyPublicIP
}