resource "github_repository" "terraform-first-repo" {
  name        = "first-repo-from-terraform"
  description = "My first repo created with tf"
  visibility  = "public"
  auto_init   = true
}

resource "github_repository" "terraform-second-repo" {
  name        = "second-repo-from-terraform"
  description = "My second repo created with tf"
  visibility  = "public"
  auto_init   = true
}

output "Terraform-repo-output1" {
  value = github_repository.terraform-first-repo.html_url
}

output "Terraform-repo-output2" {
  value = github_repository.terraform-second-repo.html_url
}
// for distroy particular resource = terraform destroy --target github_repository.terraform-first-repo